//
//  ViewController.swift
//  Example
//
//  Created by p-x9 on 2022/09/11.
//  
//

import UIKit
import OrderedCollections

class ViewController: UIViewController {
    
    let vi = View()
    
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
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    func setupViews() {
        view.addSubview(vi)
        
        vi.tableView.register(KeyValueTableViewCell.self, forCellReuseIdentifier: "\(KeyValueTableViewCell.self)")
        vi.tableView.dataSource = self
        vi.tableView.delegate = self
        
        refreshUserDefaultsTable()
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
    
    func setupNavigationItems() {
        let addBarButtonItem = UIBarButtonItem(image: .init(systemName: "plus"), style: .plain,
                                               target: self, action: #selector(addItem))
        
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    func refreshUserDefaultsTable() {
        self.dictionary = userDefaults.dictionaryRepresentation()
        self.vi.tableView.reloadData()
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
