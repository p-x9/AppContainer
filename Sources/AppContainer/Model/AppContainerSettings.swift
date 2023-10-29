//
//  AppContainerSettings.swift
//  
//
//  Created by p-x9 on 2022/09/09.
//  
//

import Foundation

/// Setting information for AppContainer
struct AppContainerSettings: Codable {
    /// UUID of the currently active container.
    var currentContainerUUID: String
}
