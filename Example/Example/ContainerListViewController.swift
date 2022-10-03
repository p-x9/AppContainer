//
//  ContainerListViewController.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit
import AppContainer

class ContainerListViewController: UIViewController {
    
    let vi = View()
    
    let appContainer: AppContainer
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupViewConstraints()
        title = "App Containers"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.addSubview(vi)
        
        vi.tableView.register(AppContainerTableViewCell.self, forCellReuseIdentifier: "\(AppContainerTableViewCell.self)")
        vi.tableView.dataSource = self
        vi.tableView.delegate = self
    }
    
    func setupViewConstraints() {
        vi.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vi.topAnchor.constraint(equalTo: view.topAnchor),
            vi.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vi.leftAnchor.constraint(equalTo: view.leftAnchor),
            vi.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
}

extension ContainerListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appContainer.containers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(AppContainerTableViewCell.self)",
                                                 for: indexPath) as! AppContainerTableViewCell
        
        let container = appContainer.containers[indexPath.row]
        cell.configure(with: container)
        return cell
    }
}

extension ContainerListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TransitionPresenter.pushContainerViewController(for: appContainer.containers[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return .init(actions: [])
    }
}

extension ContainerListViewController {
    class View: UIView {
        let tableView = UITableView(frame: .null, style: .insetGrouped)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupViews()
            setupViewConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupViews() {
            addSubview(tableView)
        }
        
        func setupViewConstraints() {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: topAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
                tableView.leftAnchor.constraint(equalTo: leftAnchor),
                tableView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        }
    }
}
