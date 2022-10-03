//
//  ContainerViewController.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit
import AppContainer

class ContainerViewController: UIViewController {
    
    struct Item {
        let name: String
        let keyPath: PartialKeyPath<Container>
    }
    
    let container: Container
    
    let vi = View()
    
    let items: [Item] = [
        .init(name: "Name", keyPath: \.name),
        .init(name: "UUID", keyPath: \.uuid),
        .init(name: "isDefault", keyPath: \.isDefault),
        .init(name: "Description", keyPath: \.description),
        .init(name: "CreatedAt", keyPath: \.createdAt),
        .init(name: "LastActivatedDate", keyPath: \.lastActivatedDate),
        .init(name: "ActivatedCount", keyPath: \.activatedCount)
    ]
    
    init(container: Container) {
        self.container = container
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        view.addSubview(vi)
        
        vi.tableView.register(KeyValueTableViewCell.self, forCellReuseIdentifier: "\(KeyValueTableViewCell.self)")
        vi.tableView.dataSource = self
        vi.tableView.delegate = self
    }
    
    private func setupViewConstraints() {
        vi.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vi.topAnchor.constraint(equalTo: view.topAnchor),
            vi.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vi.leftAnchor.constraint(equalTo: view.leftAnchor),
            vi.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
}

extension ContainerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(KeyValueTableViewCell.self)",
                                                 for: indexPath) as! KeyValueTableViewCell
        
        let item = items[indexPath.row]
        cell.configure(key: item.name, value: container[keyPath: item.keyPath])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Information"
    }
}

extension ContainerViewController: UITableViewDelegate {
    
}

extension ContainerViewController {
    class View: UIView {
        let tableView = UITableView(frame: .null, style: .grouped)
        
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
