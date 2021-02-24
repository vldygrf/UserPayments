//
//  PaymentCell.swift
//  UserPayments
//
//  Created by Vladislav Garifulin on 24.02.2021.
//

import Foundation
import UIKit

class PaymentCell: UITableViewCell {
    var value: Dictionary<String, Any>? {
        didSet {
            if let desc = value?["desc"] as? String {
                textLabel?.text = desc
                
                if let created = value?["created"] as? Double {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    textLabel?.text?.append(" (\(dateFormatter.string(from: Date(timeIntervalSince1970: created))))")
                }
            }
            
            if let amount = value?["amount"] as? Double {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.maximumFractionDigits = 2
                if let currency = value?["currency"] as? String {
                    formatter.currencyCode = currency
                }
    
                detailTextLabel?.text = (formatter.string(from: NSNumber(value: amount)))
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    func initCommon() {
        textLabel?.numberOfLines = 0
    }
}
