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
        slideMethod(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
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
        slideMethod(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
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
    private var currentWorkerInfo = [DatabaseManager.EmployeeInfo]()
    
    //MARK: View
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Button Outlet
    @IBOutlet private weak  var newProductButton: UIButton!
    @IBOutlet private weak var statisticsButton: DesignButton!
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
        transitionViewLeftConstraint.constant = -transitionView.bounds.width
        
        NetworkManager.shared.downloadEmployeeInfo(success: { workerInfo in
            self.currentWorkerInfo = workerInfo
            self.currentWorkerInfo.forEach { (workerInfo) in
                self.nameLabel.text = workerInfo.name
                self.positionLabel.text = workerInfo.position
                
                if workerInfo.position == NavigationCases.WorkerInfoCases.admin.rawValue && AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid{
                    self.newProductButton.isHidden = false
                    self.statisticsButton.isHidden = false
                }
            }
            self.emailLabel.text = Auth.auth().currentUser?.email
        }) { error in
            self.present(UIAlertController.somethingWrong(), animated: true)
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
            self.present(UIAlertController.rePassword(success: {
                self.dismiss(animated: true) { let ordersVC = self.storyboard?.instantiateViewController(withIdentifier: NavigationCases.IDVC.OrderListVC.rawValue) as? OrderListViewController
                    self.view.window?.rootViewController = ordersVC
                    self.view.window?.makeKeyAndVisible()
                }
            }, password: newPass), animated: true)
        }
    }
    
}

//MARK: -

