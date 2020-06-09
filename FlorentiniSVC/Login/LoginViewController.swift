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
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Произошла ошибка с пользовательской информацией: \(error.localizedDescription)"), animated: true)
        }
        
        hideKeyboardWhenTappedAround()
        activityIndicator.stopAnimating()
        
    }
    
    //MARK: - Login tapped
    @IBAction private func loginTapped(_ sender: UIButton) {
        activityIndicator.startAnimating()
        let email = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthenticationManager.shared.signIn(email: email, password: password, success: { result in
            let uid = result.user.uid
            
            NetworkManager.shared.downloadDataOfCertainEmployee(uid: uid, success: { (employeeData) in
                //crash if uid is not exist in employees database path
                //firebase have not an opportunity to delete certain user by admin. Firebase Admin SDK is not working with Swift yet
                if let name = employeeData.map({$0.name}).first,
                    let position = employeeData.map({$0.position}).first {
                    self.present(UIAlertController.saveSignInConfirmation(self.activityIndicator, success: {
                        CoreDataManager.shared.saveEmployee(name: name, position: position, email: email, password: password, uid: uid) {
                            self.activityIndicator.stopAnimating()
                            self.signInTransition()
                        }
                    }), animated: true)
                }else{
                    self.activityIndicator.stopAnimating()
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
                }
            }) { (error) in
                self.activityIndicator.stopAnimating()
                print(error.localizedDescription)
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15) {
                self.activityIndicator.stopAnimating()
            }
            
        }) { error in
            self.activityIndicator.stopAnimating()
            print(error.localizedDescription)
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание!", message: "Проблема с интернетом. Аунтефикация не произошла"), animated: true)
        }
    }
    
    //MARK: - Implementation
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    //MARK: - Activity Indicator
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
}









//MARK: - Extension

private extension LoginViewController {
    
    func signInTransition() {
        let orderListStoryboard = UIStoryboard(name: "TabBar", bundle: Bundle.main)
        guard let destinationVC = orderListStoryboard.instantiateInitialViewController() else {
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Attention", message: "Navigation error"), animated: true)
            return}
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}
