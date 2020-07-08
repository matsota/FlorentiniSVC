//
//  UIVC + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 24.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit


extension UIViewController {
    //MARK: Connection lost
    func alertAboutConnectionLost(method name: String, error: Error) {
        self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
        print("ERROR: \(self): \(name) ", error.localizedDescription)
    }
    
    //MARK: Keyboard
    @objc func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: Set Text View
    func cutomsTextView(for textView: UITextView, placeholder: String) {
        textView.font = UIFont(name: "System", size: 15)
        if textView.text == "" {
            textView.text = placeholder
            textView.textColor = .systemGray4
            
        }
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 5
        textView.returnKeyType = .done
    }
    func changeTextViewHeightDependsOnTextLength(_ textView: UITextView, for constaint: NSLayoutConstraint) {
        let width = textView.frame.size.width,
        height = constaint.constant
        textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        if height < 34 * 2.5 {
            let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
            constaint.constant = newFrame.height
            textView.frame = newFrame
        }
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










