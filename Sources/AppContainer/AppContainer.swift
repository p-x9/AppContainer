import Foundation

public class AppContainer {
    public static let standard = AppContainer()
    
    private let fileManager = FileManager.default
    
    /// home directory url
    private lazy var homeDirectoryUrl: URL = {
        URL(fileURLWithPath: NSHomeDirectory())
    }()
    
    /// home directory path
    private var homeDirectoryPath: String {
        homeDirectoryUrl.path
    }
    
    /// url of app container stashed
    /// ~/Library/.__app_container__
    private lazy var containersUrl: URL = {
        homeDirectoryUrl.appendingPathComponent("Library").appendingPathComponent(Constants.containerFolderName)
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
    
    private var groupIdentifier: String?
    
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
    
    /// suite names of UserDefaults.
    private var cachedSuiteNames = [String]()
    
    private init() {
        setup()
    }
    
    /// initialize with app group identifier.
    /// - Parameter groupIdentifier: app group identifier.
    public init(groupIdentifier: String) {
        guard let homeDirectoryUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            fatalError("Invalid app group identifier")
        }
        
        self.homeDirectoryUrl = homeDirectoryUrl
        self.groupIdentifier = groupIdentifier
        setup()
    }
    
    private func setup() {
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
        if self.activeContainer?.uuid == container.uuid {
            return
        }
        
        try exportUserDefaults()
        
        try stash()
        
        // clear `cfprefsd`'s cache
        try syncUserDefaults()
        
        try moveContainerContents(src: container.path(homeDirectoryPath), dst: homeDirectoryPath)
        
        try syncUserDefaults()
        
        settings.currentContainerUUID = container.uuid
    }
    
    /// activate selected container
    /// - Parameter uuid: container's unique id.
    public func activateContainer(uuid: String) throws {
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try self.activate(container: container)
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
        guard fileManager.fileExists(atPath: container.path(homeDirectoryPath)) else {
            throw AppContainerError.containerDirectoryNotFound
        }
        
        if settings.currentContainerUUID == container.uuid {
            try activate(container: .default)
        }
        
        try fileManager.removeItem(at: container.url(homeDirectoryUrl))
    }
    
    /// Delete Selected container.
    /// - Parameter uuid: uuid of container that you want to delete.
    public func deleteContainer(uuid: String) throws {
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try self.delete(container: container)
    }
    
    /// Clear contents in selected container
    /// - Parameter container: target container.  Since only the uuid of the container is considered, `cleanContainer(uuid: String)`method  can be used instead.
    public func clean(container: Container) throws {
        guard fileManager.fileExists(atPath: container.path(homeDirectoryPath)) else {
            throw AppContainerError.containerDirectoryNotFound
        }
        
        try Container.Directories.allCases.forEach { directory in
            let url = container.url(homeDirectoryUrl).appendingPathComponent(directory.name)
            try self.fileManager.removeChildContents(at: url, excludes: directory.excludes)
        }
    }
    
    /// Clear contents in selected container
    /// - Parameter uuid: uuid of container that you want to clean.
    public func cleanContainer(uuid: String) throws {
        guard let container = self.containers.first(where: { $0.uuid == uuid }) else {
            return
        }
        
        try self.clean(container: container)
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
        try Container.Directories.allCases.forEach { directory in
            let source = src + "/" + directory.name
            let destination = dst + "/" + directory.name
            
            try fileManager.createDirectoryIfNotExisted(atPath: destination, withIntermediateDirectories: true)
            try fileManager.removeChildContents(atPath: destination, excludes: directory.excludes)
            try fileManager.moveChildContents(atPath: source, toPath: destination, excludes: directory.excludes)
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

// MARK: - UserDefaults
extension AppContainer {
    private func syncUserDefaults() throws {
        cachedSuiteNames.forEach {
            syncUserDefaults(suiteName: $0)
        }
    }
    
    private func syncUserDefaults(suiteName: String?) {
        guard let plistName = suiteName ?? Bundle.main.bundleIdentifier else { return }
        let plistUrl = homeDirectoryUrl.appendingPathComponent("Library/Preferences/\(plistName).plist")
        
        let applicationID: CFString
        if let suiteName = suiteName, suiteName != Bundle.main.bundleIdentifier {
            applicationID = suiteName as CFString
        } else {
            applicationID = kCFPreferencesCurrentApplication
        }
        
        var udKeys = [CFString]()
        if let keys = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost) {
            udKeys = [CFString](keys)
        }
        
        guard let plistDictionary = NSDictionary(contentsOf: plistUrl) as? [String : Any] else {
            udKeys.forEach {
                CFPreferencesSetAppValue($0, nil, applicationID)
            }
            return
        }
        
        udKeys.forEach { key in
            if let value = plistDictionary[key as String] {
                CFPreferencesSetAppValue(key, value as CFPropertyList, applicationID)
            } else {
                CFPreferencesSetAppValue(key, nil, applicationID)
            }
        }
        
        for (key, value) in plistDictionary {
            CFPreferencesSetAppValue(key as CFString, value as CFPropertyList, applicationID)
        }
    }
    
    private func exportUserDefaults() throws {
        let preferencesUrl = homeDirectoryUrl.appendingPathComponent("Library/Preferences")
        let suites = try fileManager.contentsOfDirectory(atPath: preferencesUrl.path)
            .filter { $0.hasSuffix(".plist") }
            .compactMap { $0.components(separatedBy: ".plist").first }

        cachedSuiteNames = suites
        
        try suites.forEach {
            try exportUserDefaults(suiteName: $0)
        }
    }
    
    private func exportUserDefaults(suiteName: String?) throws {
        guard let plistName = suiteName ?? Bundle.main.bundleIdentifier else { return }
        let plistUrl = homeDirectoryUrl.appendingPathComponent("Library/Preferences/\(plistName).plist")
        
        let applicationID: CFString
        if let suiteName = suiteName, suiteName != Bundle.main.bundleIdentifier {
            applicationID = suiteName as CFString
        } else {
            applicationID = kCFPreferencesCurrentApplication
        }
        
        CFPreferencesAppSynchronize(applicationID)
        
        guard let keys = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost),
              let dictionary = CFPreferencesCopyMultiple(keys, applicationID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost) as? Dictionary<String, Any> else {
            try fileManager.removeItem(at: plistUrl)
            return
        }
        
        let plistData = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
        try plistData.write(to: plistUrl)
    }
    
}
