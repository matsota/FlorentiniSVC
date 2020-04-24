//
//  ProfileViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    //MARK: - Override
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forViewDidLoad()
        
    }
    
    //MARK: - Transition menu tapped
    @IBAction private func transitionMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    //MARK: - Transition confirm
    @IBAction func transitionConfirm(_ sender: UIButton) {
        guard let title = sender.currentTitle,
               let view = transitionView,
               let constraint = transitionViewLeftConstraint,
               let button = transitionDismissButton else {return}
               
        transitionPerform(by: title, for: view, with: constraint, dismiss: button)
    }
    
    
    //MARK: - Transition dismiss
    @IBAction private func transitionMenuDismiss(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    //MARK: - New password tapped
    @IBAction private func changePasswordTapped(_ sender: DesignButton) {
        passwordView.isHidden = !passwordView.isHidden
    }
    
    
    //MARK: - New password confirmed
    @IBAction private func passwordConfirmTapped(_ sender: UIButton) {
        changesConfirmed()
    }
    
    //MARK: - Private Implementation
    
    //MARK: View
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Button Outlet

    @IBOutlet private var adminButtons: [DesignButton]!
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    
    //MARK: Label Outlet
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    
    //MARK: TextField Outlet
    @IBOutlet private weak var newPassword: UITextField!
    @IBOutlet private weak var reNewPassword: UITextField!
    
    //MARK: Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
    
}









//MARK: - Extention:

//MARK: - For Overrides
private extension ProfileViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {
        
        CoreDataManager.shared.fetchEmployeeData(success: { (data) -> (Void) in
            guard let name = data.map({$0.name}).first,
            let email = data.map({$0.email}).first,
            let position = data.map({$0.position}).first,
            let uid = data.map({$0.uid}).first else {
                print("ERROR: Profile/CoreDataManager.shared.fetchEmployeeData/guard_let_else")
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Ошибка Аунтификации. Выйдите и перезагрузите приложение"), animated: true)
                return
            }
            if position == NavigationCases.EmployeeCases.admin.rawValue && uid == AuthenticationManager.shared.uidAdmin {
                self.adminButtons.forEach { (button) in
                    button.isHidden = false
                }
            }
            self.nameLabel.text = name
            self.emailLabel.text = email
            self.positionLabel.text = position
        }) { (error) in
            print("ERROR: Profile/CoreDataManager.shared.fetchEmployeeData: ", error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Ошибка Аунтификации. Выйдите и перезагрузите приложение"), animated: true)
        }
    }
    
}

//MARK: -

//MARK: - Change Password
private extension ProfileViewController{
    
    func changesConfirmed() {
        guard let newPass = newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let reNewPass = reNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        
        if newPass != reNewPass {
            self.present(UIAlertController.classic(title: "Внимание", message: "Пароли не совпадают"), animated: true)
        }else if newPass == "" || reNewPass == "" {
            self.present(UIAlertController.classic(title: "Внимание", message: "Для смены пароля необходимо заполнить все поля"), animated: true)
        }else{
            self.present(UIAlertController.updatePassword({
                AuthenticationManager.shared.updatePassword(newPass) {
                    self.transitionToExit(title: "Успех!", message: "Перезайдите в приложение")
                }
            }), animated: true)
        }
    }
    
}

//MARK: -

