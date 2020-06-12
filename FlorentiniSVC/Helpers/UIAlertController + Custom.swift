//
//  UIAlertController + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 27.12.2019.
//  Copyright © 2019 Andrew Matsota. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    //MARK: - Classic with OK button
    static func classic (title: String, message: String) -> (UIAlertController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК",  style: .default) {(action) in}
        alertController.addAction(action)
        
        return (alertController)
    }
    static func somethingWrong() -> (UIAlertController){
        let alertController = UIAlertController(title: "Упс!", message: "Что-то пошло не так", preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК",  style: .default) {(action) in}
        alertController.addAction(action)
        return (alertController)
    }

    //MARK: - Alert APPEARANCE
    static func alertAppearanceForHalfSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
    static func alertAppearanceForTwoSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
    
    
    //MARK: - CONFIRMATION
    static func confirmAnyStyleAlert(message: String, confirm: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (_) in
            confirm()
        }))
        return alert
    }
    static func confirmAnyStyleAlert(message: String, confirm: @escaping() -> Void, cancel: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (_) in
            cancel()
        }))
            
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (_) in
            confirm()
        }))
        return alert
    }
    static func confirmAnyStyleActionSheet(message: String, confirm: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (_) in
            confirm()
        }))
        return alert
    }
    
    //MARK: - PENETRATION
    static func setNewString(message: String, placeholder: String, confirm: @escaping(String) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
            
        alert.addTextField { (text:UITextField) in
            text.placeholder = placeholder
            text.keyboardAppearance = .dark
            text.keyboardType = .default
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (action: UIAlertAction) in
            guard let newString = alert.textFields?.first?.text else {return}
            confirm(newString)
        }))
        return alert
    }
    static func setNewInteger(message: String, confirm: @escaping(Int) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
            
        alert.addTextField { (text:UITextField) in
            text.keyboardType = .numberPad
            text.placeholder = "Введите Число"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { (action: UIAlertAction) in
            guard let newInteger = Int((alert.textFields?.first?.text)!)  else {return}
            confirm(newInteger)
        }))
        return alert
    }
    static func addSubCategory(message: String, confirm: @escaping(String) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Выберите Категорию", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Добавить к Цветам", style: .default, handler: { (action: UIAlertAction) in
            let string = NavigationCases.ProductCategoriesCases.flower.rawValue
            confirm (string)
        }))
        alert.addAction(UIAlertAction(title: "Добавить к Подаркам", style: .default, handler: { (action: UIAlertAction) in
            let string = NavigationCases.ProductCategoriesCases.gift.rawValue
            confirm (string)
        }))
        alert.addAction(UIAlertAction(title: "Добавить к Букетам", style: .default, handler: { (action: UIAlertAction) in
            let string = NavigationCases.ProductCategoriesCases.bouquet.rawValue
            confirm (string)
        }))
        return alert
    }

}
