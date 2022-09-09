import Foundation

public class AppContainer {
    public static let standard = AppContainer()
    
    private let fileManager = FileManager.default
    
    /// home directory url
    private lazy var homeDirectoryUrl: URL = {
        fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }()
    
    /// home directory path
    private var homeDirectoryPath: String {
        homeDirectoryUrl.path
    }
    
    /// url of app container stashed
    /// ~/Library/.__app_container__
    private lazy var containersUrl: URL = {
        homeDirectoryUrl.appendingPathComponent(Constants.containerFolderName)
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
    
    /// Active Container.
    /// The original content now exists in the home directory.
    public var activeContainer: Container? {
        _containers.first(where: { $0.uuid == settings.currentContainerUUID })
    }
    
    /// container list
    public var containers: [Container] {
        _containers
    }
    
    private lazy var _containers: [Container] = {
        (try? loadContainers()) ?? []
    }()

    private var activeContainerIndex: Int? {
        _containers.firstIndex(where: { $0.uuid == settings.currentContainerUUID })
    }
    
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
        try moveContainerContents(src: container.path(homeDirectoryPath), dst: homeDirectoryPath)
        
        settings.currentContainerUUID = uuid
    }
    
    /// Evacuate currently used container.
    public func stash() throws {
        guard let container = self.activeContainer else {
            return
        }
        
        try cleanContainerDirectory(container: container)
        try moveContainerContents(src: homeDirectoryPath, dst: container.path(homeDirectoryPath))
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
        guard fileManager.fileExists(atPath: container.path(homeDirectoryPath)) else {
            return
        }
        
        if settings.currentContainerUUID == uuid {
            try activate(container: .default)
        }
        
        try fileManager.removeItem(at: container.url(homeDirectoryUrl))
    }
    
    /// Clear contents in selected container
    /// - Parameter container: target container.  Since only the uuid of the container is considered, `cleanContainer(uuid: String)`method  can be used instead.
    public func clean(container: Container) throws {
        try self.cleanContainer(uuid: container.uuid)
    }
    
    /// Clear contents in selected container
    /// - Parameter uuid: uuid of container that you want to clean.
    public func cleanContainer(uuid: String) throws {
        let container = Container(uuid: uuid)
        guard fileManager.fileExists(atPath: container.path(homeDirectoryPath)) else {
            return
        }
        
        try Container.Directories.allNames.forEach { name in
            let url = container.url(homeDirectoryUrl).appendingPathComponent(name)
            try self.fileManager.removeChildContents(at: url)
        }
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
        guard !fileManager.fileExists(atPath: Container.default.path(homeDirectoryPath)) else {
            return
        }
        
        let container = try createNewContainer(name: "DEFAULT", isDefault: true)
        
        try moveContainerContents(src: homeDirectoryPath, dst: container.path(homeDirectoryPath))
    }
    
    @discardableResult
    private func createNewContainer(name: String, isDefault: Bool) throws -> Container {
        let container: Container = isDefault ? .default : .init(name: name, uuid: UUID().uuidString)
        
        // create containers directory if needed
        try createContainerDirectoryIfNeeded()
        
        // create container directory
        try fileManager.createDirectoryIfNotExisted(at: container.url(homeDirectoryUrl), withIntermediateDirectories: true)
        
        try Container.Directories.allNames.forEach { name in
            let url = container.url(homeDirectoryUrl).appendingPathComponent(name)
            try self.fileManager.createDirectoryIfNotExisted(at: url,
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
        guard fileManager.fileExists(atPath: container.path(homeDirectoryPath)) else {
            return
        }
        
        let plistUrl = container.url(homeDirectoryUrl).appendingPathComponent(Constants.containerInfoPlistName)
        
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
            let url = container.url(homeDirectoryUrl).appendingPathComponent(name)
            try self.fileManager.removeItemIfExisted(at: url)
        }
    }
}
