//
//  TransitionPresenter.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit
import AppContainer

enum TransitionPresenter {
    static func pushAppContainerTableViewController(for appContainer: AppContainer) {
        let vc = ContainerListViewController(appContainer: appContainer)
        UIApplication.shared.topViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func pushContainerViewController(for container: Container) {
        let vc = ContainerViewController(container: container)
        UIApplication.shared.topViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
