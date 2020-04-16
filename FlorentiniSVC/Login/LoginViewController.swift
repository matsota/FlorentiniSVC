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
        
        CoreDataManager.shared.fetchEmployeeData(success: { (data) -> (Void) in
            if let _ = data.map({$0.name}).first,
                let _ = data.map({$0.position}).first,
                let _ = data.map({$0.email}).first,
                let _ = data.map({$0.password}).first {
                self.signInTransition()
            }
        }) { (error) in
            print(error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Произошла ошибка с пользовательской информацией: \(error.localizedDescription)"), animated: true)
        }
        
    }
    
    //MARK: - Login tapped
    @IBAction private func loginTapped(_ sender: UIButton) {
        
        let email = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthenticationManager.shared.signIn(email: email, password: password, success: { result in
            let uid = result.user.uid
            
            NetworkManager.shared.fetchEmployeeDataOnes(uid: uid, success: { (employeeData) in
                if let name = employeeData.map({$0.name}).first,
                    let position = employeeData.map({$0.position}).first {
                    self.present(UIAlertController.saveSignIn(success: {
                        CoreDataManager.shared.saveEmployee(name: name, position: position, email: email, password: password, uid: uid) {
                            self.signInTransition()
                        }
                    }, failure: {
                        self.signInTransition()
                    }), animated: true)
                }else{
                    self.present(UIAlertController.completionDoneTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
                }
            }) { (error) in
                print(error.localizedDescription)
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
            }
        }) { error in
            print(error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
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
