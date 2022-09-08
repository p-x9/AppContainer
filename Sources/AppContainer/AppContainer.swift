import Foundation

public class AppContainer {
    public static let shared = AppContainer()
    
    private let fileManager = FileManager.default
    
    private lazy var containerUrl: URL = {
        fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Constants.containerFolderName)
    }()
    
    private lazy var settingsUrl: URL = {
        containerUrl.appendingPathComponent(Constants.appContainerSettingsPlistName)
    }()
    
    private lazy var settings: AppContainerSettings = {
        loadAppContainerSettings() ?? .init(currentContainerUUID: UUID.zero.uuidString)
    }() {
        didSet {
            try? updateAppContainerSettings(settings: settings)
        }
    }
    
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
    
    @discardableResult
    public func createNewContainer(name: String) throws -> Container {
        try createNewContainer(name: name, isDefault: false)
    }
    
    public func activate(container: Container) throws {
        try activateContainer(uuid: container.uuid)
    }
    
    public func activateContainer(uuid: String) throws {
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try stash()
        try moveContainerContents(src: container.path, dst: NSHomeDirectory())
        
        settings.currentContainerUUID = uuid
    }
    
    public func stash() throws {
        let uuid = self.settings.currentContainerUUID
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try cleanContainerDirectory(container: container)
        try moveContainerContents(src: NSHomeDirectory(), dst: container.path)
    }
    
    public func delete(container: Container) throws {
        try deleteContainer(uuid: container.uuid)
    }
    
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
    
    public func reset() throws {
        try activate(container: .default)
        
        try fileManager.removeItem(at: containerUrl)
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
        try fileManager.createDirectory(at: containerUrl, withIntermediateDirectories: true)
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
    
    private func loadContainers() throws -> [Container] {
        guard fileManager.fileExists(atPath: containerUrl.path) else {
            return []
        }
        
        let decoder = PropertyListDecoder()
        let uuids = try fileManager.contentsOfDirectory(atPath: containerUrl.path)
        let containers: [Container] = uuids.compactMap { uuid in
            let url = containerUrl.appendingPathComponent(uuid)
            let plistUrl = url.appendingPathComponent(Constants.containerInfoPlistName)
            guard let data = try? Data(contentsOf: plistUrl) else {
                return nil
            }
            return try? decoder.decode(Container.self, from: data)
        }
        
        return containers
    }
    
    private func moveContainerContents(src: String, dst: String) throws {
        try Container.Directories.allNames.forEach { name in
            let source = src + "/" + name
            let destination = dst + "/" + name
            
            try fileManager.createDirectoryIfNotExisted(atPath: destination, withIntermediateDirectories: true)
            try fileManager.removeChildContents(atPath: destination)
            try fileManager.moveChildContents(atPath: source, toPath: destination)
        }
    }
    
    private func cleanContainerDirectory(container: Container) throws {
        try Container.Directories.allNames.forEach { name in
            try self.fileManager.removeItemIfExisted(at: container.url.appendingPathComponent(name))
        }
    }
}
