//
//  LoginViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AuthenticationManager.shared.currentUser?.uid as Any)
        
        if AuthenticationManager.shared.currentUser != nil {
            self.signInTransition()
        }
    }
    
    @IBAction private func loginTapped(_ sender: UIButton) {
        
        let email = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthenticationManager.shared.signIn(email: email, password: password, success: { _ in
            self.signInTransition()
        }) { (error) in
            self.present(UIAlertController.classic(title: "Attention", message: error.localizedDescription), animated: true)
        }
    }
    
    //MARK: - Implementation
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
}









//MARK: - Extension

private extension LoginViewController {
    
    func signInTransition() {
        let orderListStoryboard = UIStoryboard(name: "OrderList", bundle: Bundle.main)
        guard let destinationVC = orderListStoryboard.instantiateViewController(withIdentifier: NavigationCases.IDVC.OrderListVC.rawValue) as? OrderListViewController else {
            self.present(UIAlertController.completionDoneTwoSec(title: "Attention", message: "Navigation error"), animated: true)
            return}
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}
