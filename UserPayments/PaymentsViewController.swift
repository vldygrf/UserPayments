//
//  ViewController.swift
//  UserPayments
//
//  Created by Vladislav Garifulin on 24.02.2021.
//

import UIKit

class PaymentsViewController: UIViewController{
    override func loadView() {
        view = PaymentsView()
    }
    
    func view() -> PaymentsView {
        return view as! PaymentsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(logout(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Login", comment: ""), style: .plain, target: self, action: #selector(login(sender:)))
        navigationItem.title = NSLocalizedString("Payments", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        login(sender: self)
    }
    
    @objc func logout(sender: UIBarButtonItem) {
        API.shared.logout()
        view().items = nil
    }
    
    @objc func login(sender: AnyObject) {
        let ac = UIAlertController(title: NSLocalizedString("Login", comment: ""), message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
            if let login = ac.textFields?[0].text, let password = ac.textFields?[1].text {
                API.shared.connect(login: login, password: password) { [weak self] (error) in
                    guard let self = self else {
                        return
                    }

                    if (error == nil) {
                        API.shared.payments { [weak self] (error, payments) in
                            if (error == nil) {
                                DispatchQueue.main.async {
                                    self?.view().items = payments
                                }
                            }else {
                                self?.present(error: error!)
                            }
                        }
                    }else {
                        self.present(error: error!)
                    }
                }
            }
        }))
        
        ac.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("Login", comment: "")
        })
        
        ac.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("Password", comment: "")
            textField.isSecureTextEntry = true
        })
    
        present(ac, animated: true)
    }
    
    private func present(error: Error) {
        DispatchQueue.main.async {
            let apiError = error as? APIError
            
            let errorMessage: String
            switch apiError {
                case let .httpQueryError(_, message):
                    errorMessage = message
                default:
                    errorMessage = error.localizedDescription
            }
            
            let ac = UIAlertController(title: NSLocalizedString("An error occurred", comment: ""),
                message: NSLocalizedString(errorMessage, comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            
            self.present(ac, animated: true, completion: nil)
        }
    }
}

