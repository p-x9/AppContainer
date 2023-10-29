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

/// View to display list of existing containers
@available(iOS 14, *)
public class ContainerListViewController: UIViewController {

    /// Target appContainer
    public let appContainer: AppContainer

    /// Default initializer
    /// - Parameters:
    ///   - appContainer: instance of ``AppContainer``.
    public init(appContainer: AppContainer) {
        self.appContainer = appContainer

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
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
        NSLayoutConstraint.activate([
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

#endif
