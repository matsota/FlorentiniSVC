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
        
        self.navigationController?.navigationBar.topItem?.title = "Профиль"
        
        CoreDataManager.shared.fetchEmployeeData(success: { (data) -> (Void) in
            guard let name = data.map({$0.name}).first,
            let email = data.map({$0.email}).first,
            let position = data.map({$0.position}).first,
            let uid = data.map({$0.uid}).first else {
                print("ERROR: Profile/CoreDataManager.shared.fetchEmployeeData/guard_let_else")
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ошибка Аунтификации. Выйдите и перезагрузите приложение"), animated: true)
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
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ошибка Аунтификации. Выйдите и перезагрузите приложение"), animated: true)
        }
        
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
    
    //MARK: Button Outlet

    @IBOutlet private var adminButtons: [DesignButton]!
    
    
    //MARK: Label Outlet
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    
    //MARK: TextField Outlet
    @IBOutlet private weak var newPassword: UITextField!
    @IBOutlet private weak var reNewPassword: UITextField!
    
    //MARK: Constraint
    @IBOutlet private weak var transitionBottomConstraint: NSLayoutConstraint!
    
}









//MARK: - Extention:

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
            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "Подтвердите смену пароля", confirm: {
                AuthenticationManager.shared.updatePassword(newPass) {
                    self.transitionToExit(title: "Успех!", message: "Перезайдите в приложение")
                }
            }), animated: true)
        }
    }
    
}

//MARK: -

