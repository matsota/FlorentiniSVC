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
    
    //call in viewdidload
    @objc func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
}

//MARK: - Transition process between storyboards
extension UIViewController {
    
    //MARK: Hide and Show Transition Menu
    func slideInTransitionMenu(for view: UIView, constraint distance: NSLayoutConstraint, dismissBy button: UIButton) {
        let viewWidth = view.bounds.width
        button.isUserInteractionEnabled = !button.isUserInteractionEnabled
        
        if distance.constant == viewWidth {
            distance.constant = 0
            UIView.animate(withDuration: 0.5) {
                button.alpha = 0
                self.view.layoutIfNeeded()
            }
        }else{
            distance.constant = viewWidth
            UIView.animate(withDuration: 0.5) {
                button.alpha = 0.5
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: To Orders storyboard
    func transitionToHomeStoryboard(success: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let storyboard = UIStoryboard(name: "OrderList", bundle: Bundle.main)
            guard let destination = storyboard.instantiateViewController(withIdentifier: NavigationCases.IDVC.OrderListVC.rawValue) as? OrderListViewController else {
                self.present(UIAlertController.completionDoneTwoSec(title: "Attention", message: "Navigation error"), animated: true)
                return}
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        success()
    }
    
    //MARK: To Catalog storyboard
    func transitionToCatalogStoryboard(success: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let storyboard = UIStoryboard(name: "CatalogList", bundle: Bundle.main)
            guard let destination = storyboard.instantiateViewController(withIdentifier: NavigationCases.IDVC.CatalogListVC.rawValue) as? CatalogListViewController else {
                self.present(UIAlertController.completionDoneTwoSec(title: "Attention", message: "Navigation error"), animated: true)
                return}
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        success()
    }
    
    //MARK: To Profile storyboard
    func transitionToProfileStoryboard(success: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
            guard let destination = storyboard.instantiateViewController(withIdentifier: NavigationCases.IDVC.ProfileVC.rawValue) as? ProfileViewController else {
                self.present(UIAlertController.completionDoneTwoSec(title: "Attention", message: "Navigation error"), animated: true)
                return}
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        success()
    }
    
    //MARK: To FAQ storyboard
    func transitionToFAQStoryboard(success: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let storyboard = UIStoryboard(name: "FAQ", bundle: Bundle.main)
            guard let destination = storyboard.instantiateViewController(withIdentifier: NavigationCases.IDVC.FAQVC.rawValue) as? FAQViewController else {
                self.present(UIAlertController.completionDoneTwoSec(title: "Attention", message: "Navigation error"), animated: true)
                return}
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        success()
    }
    
    //MARK: Exit
    func transitionToExit(success: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            UIApplication.shared.open(URL(string: "https://florentini.space")! as URL, options: [:], completionHandler: nil)
        }
        success()
    }
    
    
    //MARK: Destination select
    func transitionPerform (by title: String, for view: UIView, with constraint: NSLayoutConstraint, dismiss button: UIButton){
        guard let cases = NavigationCases.TranstionCases(rawValue: title) else {return}
        let view = view,
        constraint = constraint,
        button = button
        
        switch cases {
        case .homeScreen:
            transitionToHomeStoryboard() {
                self.slideInTransitionMenu(for: view, constraint: constraint, dismissBy: button)
            }
        case .catalogScreen:
            transitionToCatalogStoryboard() {
                self.slideInTransitionMenu(for: view, constraint: constraint, dismissBy: button)
            }
        case .profile:
            transitionToProfileStoryboard() {
                self.slideInTransitionMenu(for: view, constraint: constraint, dismissBy: button)
            }
        case .faqScreen:
            transitionToFAQStoryboard() {
                self.slideInTransitionMenu(for: view, constraint: constraint, dismissBy: button)
            }
        case .exit:
            transitionToExit() {
                self.slideInTransitionMenu(for: view, constraint: constraint, dismissBy: button)
            }
        }
    }
    
}










