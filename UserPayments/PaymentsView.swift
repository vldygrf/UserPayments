//
//  PaymentsView.swift
//  UserPayments
//
//  Created by Vladislav Garifulin on 24.02.2021.
//

import Foundation
import UIKit

class PaymentsView: UIView, UITableViewDataSource {
    private let tableView = UITableView()
    private let cellIdent = "paymentCell"
    var items: Array<Dictionary<String, Any>>? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    func initCommon() {
        tableView.register(PaymentCell.self, forCellReuseIdentifier: cellIdent)
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath)
        
        if let cell = cell as? PaymentCell {
            cell.value = items?[indexPath.row]
        }
        
        return cell
    }
}
