//
//  ViewController.swift
//  Example
//
//  Created by p-x9 on 2022/09/11.
//  
//

import UIKit
import AppContainer
import OrderedCollections

class ViewController: UIViewController {
    
    let vi = View()
    
    let appContainer = AppContainer.standard
    let userDefaults = UserDefaults.standard
    //init(suiteName: "group.com.p-x9.AppContainerExample")!
    
    lazy var dictionary: Dictionary<String, Any> = .init() {
        didSet {
            var dictionary = OrderedDictionary<String, Any>(uniqueKeysWithValues: dictionary)
            dictionary.sort()
            orderedDictionary = dictionary
        }
    }
    
    var orderedDictionary: OrderedDictionary<String, Any> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupViewConstraints()
        setupNavigationItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = appContainer.activeContainer?.name
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    private func setupViews() {
        view.addSubview(vi)
        
        vi.tableView.register(KeyValueTableViewCell.self, forCellReuseIdentifier: "\(KeyValueTableViewCell.self)")
        vi.tableView.dataSource = self
        vi.tableView.delegate = self
        
        refreshUserDefaultsTable()
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
    
    private func setupNavigationItems() {
        let addBarButtonItem = UIBarButtonItem(image: .init(systemName: "plus"), style: .plain,
                                               target: self, action: #selector(addItem))
        
        let containerButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.grid.3x3.square"), style: .plain, target: self, action: nil)
        
        navigationItem.leftBarButtonItem = containerButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        configureContainerMenu()
    }
    
    private func configureContainerMenu() {
        var actions = [UIMenuElement]()
        appContainer.containers.enumerated().forEach { i, container in
            let action = UIAction(title: container.name ?? "Container\(i)",
                                  subtitle: container.description,
                                  state: container == appContainer.activeContainer ? .on : .off) { [weak self] _ in
                guard let self = self,
                      container != self.appContainer.activeContainer else {
                    return
                }
                self.activate(container: container)
                self.configureContainerMenu()
            }
            actions.append(action)
        }
        let addContainerAction = UIAction(title: "Add New Container", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.addNewContainer()
        }
        
        let containerListAction = UIAction(title: "Detail...") { [weak self] _ in
            guard let self = self else { return }
            TransitionPresenter.pushAppContainerTableViewController(for: self.appContainer)
        }
        
        
        navigationItem.leftBarButtonItem?.menu = UIMenu(options: .displayInline,
                                                        children: [
                                                            UIMenu(options: .displayInline, children: actions),
                                                            UIMenu(options: .displayInline, children: [containerListAction]),
                                                            addContainerAction
                                                        ])
    }
    
    private func activate(container: Container) {
        try? self.appContainer.activate(container: container)
        
        let alert = UIAlertController(title: "Restart App",
                                      message: "please restart app to activate selected container.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            UIControl().sendAction(NSSelectorFromString("suspend"), to: UIApplication.shared, for: nil)
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                exit(0)
            }
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func refreshUserDefaultsTable() {
        self.dictionary = userDefaults.dictionaryRepresentation()
        self.vi.tableView.reloadData()
    }
    
    func addNewContainer() {
        let alert = UIAlertController(title: "Add New Container", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        guard let textField = alert.textFields?.first else {
            return
        }
        
        textField.placeholder = "Container Name"
        
        let okAction = UIAlertAction(title: "Add", style: .destructive) { [weak self] _ in
            guard let self = self, let text = textField.text, !text.isEmpty else { return }
            
            _ = try? self.appContainer.createNewContainer(name: text)
            self.configureContainerMenu()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc
    func editItem(key: String) {
        guard let type = userDefaults.extractValueType(forKey: key),
              type.isEditable else {
            return
        }
        
        let alert = UIAlertController(title: "Edit", message: "key: \(key)", preferredStyle: .alert)
        alert.addTextField()
        
        guard let textField = alert.textFields?.first else {
           return
        }
        
        textField.placeholder = "Input \(String(describing: userDefaults.extractValueType(forKey: key)))"
        textField.text = "\(userDefaults.value(forKey: key) ?? "")"
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            guard let text = textField.text, !text.isEmpty else { return }
            
            guard let value: Any = type.value(from: text) else { return }
            
            self?.userDefaults.set(value, forKey: key)
            self?.refreshUserDefaultsTable()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
    // Currently supported string only
    @objc
    func addItem() {
        let alert = UIAlertController(title: "Add", message: "Input key and value \n(string only)", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        
        guard let keyTextField = alert.textFields?[0],
              let valueTextField = alert.textFields?[1] else {
            return
        }
        
        keyTextField.placeholder = "Key"
        valueTextField.placeholder = "Value"
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            guard let key = keyTextField.text else { return }
            self?.userDefaults.set(valueTextField.text, forKey: key)
            
            self?.refreshUserDefaultsTable()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc
    func deleteItem(at index: Int) -> Bool {
        let item = self.orderedDictionary.elements[index]
        userDefaults.set(nil, forKey: item.key)
        let isDeleted = userDefaults.dictionaryRepresentation()[item.key] == nil
        if isDeleted {
            self.dictionary = userDefaults.dictionaryRepresentation()
            vi.tableView.deleteRows(at: [[0, index]], with: .automatic)
        }
        
        return isDeleted
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(KeyValueTableViewCell.self)",
                                                 for: indexPath) as! KeyValueTableViewCell
        
        let item = orderedDictionary.elements[indexPath.row]
        cell.configure(key: item.key, value: item.value)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = orderedDictionary.keys[indexPath.item]
        self.editItem(key: key)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            completionHandler(self.deleteItem(at: indexPath.item))
        }
        return .init(actions: [deleteAction])
    }
}


extension ViewController {
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

private extension UserDefaults.ValueType {
    // FIXME: - support more types
    var isEditable: Bool {
        switch self {
        case .int, .double, .string:
            return true
        default:
            return false
        }
    }
}
