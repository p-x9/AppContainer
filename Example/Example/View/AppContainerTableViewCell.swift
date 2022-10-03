//
//  AppContainerTableViewCell.swift
//  Example
//
//  Created by p-x9 on 2022/10/03.
//  
//

import UIKit
import AppContainer

class AppContainerTableViewCell: UITableViewCell {
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    let uuidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
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
    
    func setupViews() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(uuidLabel)
        
        horizontalStackView.addArrangedSubview(titleLabel)
        horizontalStackView.addArrangedSubview(descriptionLabel)
    }
    
    func setupViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
        ])
        
        NSLayoutConstraint.activate([
            horizontalStackView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            horizontalStackView.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            uuidLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            uuidLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
    }
    
    func configure(with container: Container) {
        titleLabel.text = container.name
        descriptionLabel.text = container.description
        uuidLabel.text = container.uuid
    }
}
