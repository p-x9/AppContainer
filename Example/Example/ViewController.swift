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
    
    lazy var dictionary: Dictionary<String, Any> = {
        Dictionary(uniqueKeysWithValues: userDefaults.dictionaryRepresentation().sorted(by: { $0.key < $1.key }))
    }()
    
    var orderedDictionary: OrderedDictionary<String, Any> {
        var dictionary = OrderedDictionary<String, Any>(uniqueKeysWithValues: dictionary)
        dictionary.sort()
        return dictionary
    }

    var observer: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupViewConstraints()
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
