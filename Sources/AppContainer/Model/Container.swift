//
//  Container.swift
//  
//
//  Created by p-x9 on 2022/09/08.
//  
//

import Foundation

public struct Container: Codable {
    /// container name
    public var name: String?
    /// container unique id
    public let uuid: String
}

extension Container {
    public var isDefault: Bool {
        uuid == UUID.zero.uuidString
    }
    
    // container relative path
    private var relativePath: String {
        "Library/" + Constants.containerFolderName + "/" + uuid
    }
    
    /// Container Directory url
    /// - Parameter homeUrl: home directory url.
    public func url(_ homeUrl: URL) -> URL {
        homeUrl.appendingPathComponent(relativePath)
    }
    
    /// Container Directory path
    /// - Parameter homePath: home directory path.
    public func path(_ homePath: String) -> String {
        homePath + "/" + relativePath
    }
}

extension Container {
    /// default ccontainer
    static let `default`: Container = {
        .init(name: "DEFAULT", uuid: UUID.zero.uuidString)
    }()
}

extension Container {
    enum Directories: String, CaseIterable {
        case library = "Library"
        case documents = "Documents"
        case systemData = "SystemData"
        case tmp = "tmp"
        
        var name: String {
            rawValue
        }
        
        static var allNames: [String] {
            allCases.map(\.name)
        }
    }
}
