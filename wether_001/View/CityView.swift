//
//  CityView.swift
//  wether_001
//
//  Created by Fredia Wiley on 10/6/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import UIKit

class CityView: UIView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let tableView = UITableView()
        
        let constrains = [
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
