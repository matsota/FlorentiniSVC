//
//  UIVC + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 24.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

//MARK: - Hide Keyboard
extension UIViewController {
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: Exit
    func transitionToExit(title: String, message: String) {
        CoreDataManager.shared.deleteCertainEntity(for: "EmployeeData", success: {
            AuthenticationManager.shared.signOut(success: {
                self.present(UIAlertController.alertAppearanceForHalfSec(title: title, message: message), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                    guard let destination = storyboard.instantiateViewController(withIdentifier: NavigationCases.Transition.LoginVC.rawValue) as? LoginViewController else {
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "Attention", message: "Navigation error"), animated: true)
                        return
                    }
                    self.navigationController?.pushViewController(destination, animated: true)
                }
            }) { (error) in
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ошибка в процессе выхода из профиля"), animated: true)
            }
        }) { (error) in
            print(error.localizedDescription)
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ошибка в процессе выхода из профиля"), animated: true)
        }
    }
    
}










