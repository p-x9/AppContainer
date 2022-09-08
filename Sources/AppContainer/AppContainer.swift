import Foundation

public class AppContainer {
    public static let shared = AppContainer()
    
    private let fileManager = FileManager.default
    
    /// url of app container stashed
    /// ~/Library/.__app_container__
    private lazy var containersUrl: URL = {
        fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Constants.containerFolderName)
    }()
    
    /// app container settings plist path
    private lazy var settingsUrl: URL = {
        containersUrl.appendingPathComponent(Constants.appContainerSettingsPlistName)
    }()
    
    /// app container settings
    /// if update params, automatically update plist file
    private lazy var settings: AppContainerSettings = {
        loadAppContainerSettings() ?? .init(currentContainerUUID: UUID.zero.uuidString)
    }() {
        didSet {
            try? updateAppContainerSettings(settings: settings)
        }
    }
    
    /// container list
    public var containers: [Container] {
        _containers
    }
    
    private lazy var _containers: [Container] = {
        (try? loadContainers()) ?? []
    }()

    private init() {
        try? createContainerDirectoryIfNeeded()
        try? createDefaultContainerIfNeeded()
    }
    
    /// create new app container
    /// - Parameter name: container name
    /// - Returns: created container info
    @discardableResult
    public func createNewContainer(name: String) throws -> Container {
        try createNewContainer(name: name, isDefault: false)
    }
    
    /// activate selected container
    /// - Parameter container: selected container. Since only the uuid of the container is considered, `activateContainer(uuid: String)`method  can be used instead.
    public func activate(container: Container) throws {
        try activateContainer(uuid: container.uuid)
    }
    
    /// activate selected container
    /// - Parameter uuid: container's unique id.
    public func activateContainer(uuid: String) throws {
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try stash()
        try moveContainerContents(src: container.path, dst: NSHomeDirectory())
        
        settings.currentContainerUUID = uuid
    }
    
    /// Evacuate currently used container.
    public func stash() throws {
        let uuid = self.settings.currentContainerUUID
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try cleanContainerDirectory(container: container)
        try moveContainerContents(src: NSHomeDirectory(), dst: container.path)
    }
    
    /// Delete Selected container.
    /// If an attempt is made to delete a container currently in use, make the default container active
    /// - Parameter container: container that you want to delete. Since only the uuid of the container is considered, `deleteContainer(uuid: String)`method  can be used instead.
    public func delete(container: Container) throws {
        try deleteContainer(uuid: container.uuid)
    }
    
    /// Delete Selected container.
    /// - Parameter uuid: uuid of container that you want to delete.
    public func deleteContainer(uuid: String) throws {
        let container = Container(uuid: uuid)
        guard fileManager.fileExists(atPath: container.path) else {
            return
        }
        
        if settings.currentContainerUUID == uuid {
            try activate(container: .default)
        }
        
        try fileManager.removeItem(at: container.url)
    }
    
    /// Clear all containers and activate the default container
    public func reset() throws {
        try activate(container: .default)
        
        try fileManager.removeItem(at: containersUrl)
    }
}

extension AppContainer {
    private func loadAppContainerSettings() -> AppContainerSettings? {
        guard let data = try? Data(contentsOf: settingsUrl) else {
            return nil
        }
        
        let decoder = PropertyListDecoder()
        return try? decoder.decode(AppContainerSettings.self, from: data)
    }
    
    private func updateAppContainerSettings(settings: AppContainerSettings) throws {
        if fileManager.fileExists(atPath: settingsUrl.path) {
            try fileManager.removeItem(at: settingsUrl)
        }
        
        // save plist
        let encoder = PropertyListEncoder()
        let containerData = try encoder.encode(settings)
        try containerData.write(to: settingsUrl)
    }
}

extension AppContainer {
    private func createContainerDirectoryIfNeeded() throws {
        try fileManager.createDirectory(at: containersUrl, withIntermediateDirectories: true)
    }
    
    private func createDefaultContainerIfNeeded() throws {
        guard !fileManager.fileExists(atPath: Container.default.path) else {
            return
        }
        
        let container = try createNewContainer(name: "DEFAULT", isDefault: true)
        
        try moveContainerContents(src: NSHomeDirectory(), dst: container.path)
    }
    
    @discardableResult
    private func createNewContainer(name: String, isDefault: Bool) throws -> Container {
        let container: Container = isDefault ? .default : .init(name: name, uuid: UUID().uuidString)
        
        // create containers directory if needed
        try createContainerDirectoryIfNeeded()
        
        // create container directory
        try fileManager.createDirectoryIfNotExisted(at: container.url, withIntermediateDirectories: true)
        
        try Container.Directories.allNames.forEach { name in
            try self.fileManager.createDirectoryIfNotExisted(at: container.url.appendingPathComponent(name),
                                                             withIntermediateDirectories: true)
        }
        
        _containers.append(container)
        
        // create plist
        try updateContainerInfo(for: container)
        
        return container
    }
    
    /// Update container information.
    /// Save as property list.
    /// - Parameter container: target container
    private func updateContainerInfo(for container: Container) throws {
        guard fileManager.fileExists(atPath: container.path) else {
            return
        }
        
        let plistUrl = container.url.appendingPathComponent(Constants.containerInfoPlistName)
        
        if fileManager.fileExists(atPath: plistUrl.path) {
            try fileManager.removeItem(at: plistUrl)
        }
        
        // update name
        if let matchedIndex = _containers.firstIndex(where: { $0.uuid == container.uuid }) {
            _containers[matchedIndex].name = container.name
        }
        
        // save plist
        let encoder = PropertyListEncoder()
        let containerData = try encoder.encode(container)
        try containerData.write(to: plistUrl)
    }
    
    /// load containers from app containers directory.
    /// container info is saved as property list  in container directory's root.
    /// - Returns: App containers
    private func loadContainers() throws -> [Container] {
        guard fileManager.fileExists(atPath: containersUrl.path) else {
            return []
        }
        
        let decoder = PropertyListDecoder()
        let uuids = try fileManager.contentsOfDirectory(atPath: containersUrl.path)
        let containers: [Container] = uuids.compactMap { uuid in
            let url = containersUrl.appendingPathComponent(uuid)
            let plistUrl = url.appendingPathComponent(Constants.containerInfoPlistName)
            guard let data = try? Data(contentsOf: plistUrl) else {
                return nil
            }
            return try? decoder.decode(Container.self, from: data)
        }
        
        return containers
    }
    
    /// move container's child contents
    /// - Parameters:
    ///   - src: source path.
    ///   - dst: destination path.
    private func moveContainerContents(src: String, dst: String) throws {
        try Container.Directories.allNames.forEach { name in
            let source = src + "/" + name
            let destination = dst + "/" + name
            
            try fileManager.createDirectoryIfNotExisted(atPath: destination, withIntermediateDirectories: true)
            try fileManager.removeChildContents(atPath: destination)
            try fileManager.moveChildContents(atPath: source, toPath: destination)
        }
    }
    
    /// Delete container directory contents.
    /// - Parameter container: target container
    private func cleanContainerDirectory(container: Container) throws {
        try Container.Directories.allNames.forEach { name in
            try self.fileManager.removeItemIfExisted(at: container.url.appendingPathComponent(name))
        }
    }
}
