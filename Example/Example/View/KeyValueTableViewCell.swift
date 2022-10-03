//
//  KeyValueTableViewCell.swift
//  Example
//
//  Created by p-x9 on 2022/09/11.
//  
//

import UIKit

class KeyValueTableViewCell: UITableViewCell {
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let keyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        keyLabel.text = ""
        valueLabel.text = ""
    }
    
    func setupViews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(valueLabel)
    }
    
    func setupViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 2),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor,constant: -2),
        ])
    }
    
    func configure(key: String, value: Any?) {
        keyLabel.text = key
        if let value = value as? CustomStringConvertible {
            valueLabel.text = "\(value)"
        }
    }
}
