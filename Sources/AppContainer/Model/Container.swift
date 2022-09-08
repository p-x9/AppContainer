//
//  Container.swift
//  
//
//  Created by p-x9 on 2022/09/08.
//  
//

import Foundation

public struct Container: Codable {
    var name: String?
    let uuid: String
}

extension Container {
    public var isDefault: Bool {
        uuid == UUID.zero.uuidString
    }
    
    public var url: URL {
        .init(fileURLWithPath: path)
    }
    
    public var path: String {
        NSHomeDirectory() + "/Library/" + Constants.containerFolderName + "/" + uuid
    }
}

extension Container {
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
