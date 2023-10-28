//
//  Container.swift
//
//
//  Created by p-x9 on 2022/09/08.
//
//

import Foundation

/// Model of container
///
/// Represents container information such as name, description, UUID, etc.
public struct Container: Codable, Equatable {
    /// Container name
    public var name: String?
    /// Container unique id
    public let uuid: String

    /// Container description
    public var description: String?

    /// Container created date
    public let createdAt: Date?

    /// Last activated date
    public var lastActivatedDate: Date?

    /// Container activated count
    public var activatedCount: Int? = 0
    
    /// Default initializer
    /// - Parameters:
    ///   - name: container name
    ///   - uuid: container unique identifier
    ///   - description: container description
    public init(name: String?, uuid: String, description: String? = nil) {
        self.name = name
        self.uuid = uuid
        self.description = description
        self.createdAt = Date()
    }
}

extension Container {
    /// A boolean value that indicates this container is default
    ///
    /// UUID of default container is `00000000-0000-0000-0000-000000000000`
    public var isDefault: Bool {
        uuid == UUID.zero.uuidString
    }

    /// Relative path where container is stored.
    /// Based on the app's home directory.
    private var relativePath: String {
        "Library/" + Constants.containerFolderName + "/" + uuid
    }

    /// Absolute URL where container is stored.
    /// - Parameter homeUrl: home directory url.
    public func url(_ homeUrl: URL) -> URL {
        homeUrl.appendingPathComponent(relativePath)
    }

    /// Absolute path where container is stored.
    /// - Parameter homePath: home directory path.
    public func path(_ homePath: String) -> String {
        homePath + "/" + relativePath
    }
}

extension Container {
    /// Default container
    ///
    /// The data of the app that existed before ``AppContainer`` is applied to this Default container.
    static let `default`: Container = {
        .init(name: "DEFAULT", uuid: UUID.zero.uuidString)
    }()
}

extension Container {
    enum Directories: String, CaseIterable {
        case library = "Library"
        case libraryCaches = "Library/Caches"
        case libraryPreferences = "Library/Preferences"
        case documents = "Documents"
        //        case systemData = "SystemData"
        case tmp = "tmp"

        var name: String {
            rawValue
        }

        var excludes: [String] {
            switch self {
            case .library:
                return ["Caches", "Preferences"]
            default:
                return []
            }
        }

        static var allNames: [String] {
            allCases.map(\.name)
        }
    }
}
