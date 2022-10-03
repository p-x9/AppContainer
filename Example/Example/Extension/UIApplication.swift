//
//  UIApplication.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return self.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return self.windows.first { $0.isKeyWindow }
        }
    }
    
    var topViewController: UIViewController? {
        return topViewController()
    }
    
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? self.keyWindow?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        if let alertController = controller as? UIAlertController, let presenting = alertController.presentingViewController {
            return presenting
        }
        return controller
    }
}
