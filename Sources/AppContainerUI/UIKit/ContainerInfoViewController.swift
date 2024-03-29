//
//  ContainerInfoViewController.swift
//  
//
//  Created by p-x9 on 2022/10/18.
//  
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import AppContainer

/// View to display container information
@available(iOS 14, *)
public class ContainerInfoViewController: UIViewController {

    public let appContainer: AppContainer?
    private let container: Container // FIXME:uuid

    /// Default initializer
    ///
    /// The `appContainer` may be omitted, but if it is nil, each piece of information becomes uneditable.
    /// - Parameters:
    ///   - appContainer: instance of ``AppContainer``.
    ///   - container: target container
    public init(appContainer: AppContainer?, container: Container) {
        self.appContainer = appContainer
        self.container = container

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
        let containerInfoView = ContainerInfoView(
            appContainer: appContainer,
            container: container
        )

        let vc = UIHostingController(rootView: containerInfoView)
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
