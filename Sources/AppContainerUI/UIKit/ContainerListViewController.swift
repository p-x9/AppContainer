//
//  ContainerListViewController.swift
//  
//
//  Created by p-x9 on 2022/10/18.
//  
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import AppContainer

@available(iOS 14, *)
public class ContainerListViewController: UIViewController {
    
    public let appContainer: AppContainer
    
    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewController()
    }
    
    private func setupChildViewController() {
        let containerListView = ContainerListView(
            appContainer: appContainer,
            title: title ?? ""
        )
        
        let vc = UIHostingController(rootView: containerListView)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        vc.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        vc.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

#endif
