//
//  TransitionPresenter.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit
import AppContainer
import AppContainerUI

enum TransitionPresenter {
    static func pushAppContainerTableViewController(for appContainer: AppContainer) {
        let vc = AppContainerUI.ContainerListViewController(appContainer: appContainer)
        vc.title = "App Containers"
        UIApplication.shared.topViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func pushContainerViewController(for container: Container, in appContainer: AppContainer? = nil) {
        let vc = AppContainerUI.ContainerInfoViewController(appContainer: appContainer, container: container)
        UIApplication.shared.topViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
