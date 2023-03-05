//
//  AppContainer.Notification.swift
//  
//
//  Created by p-x9 on 2023/02/27.
//  
//

import Foundation

extension AppContainer {
    public static let containerWillChangeNotification = Notification.Name("com.p-x9.appcontainer.containerWillChange")
    public static let containerDidChangeNotification = Notification.Name("com.p-x9.appcontainer.containerDidChange")
}
