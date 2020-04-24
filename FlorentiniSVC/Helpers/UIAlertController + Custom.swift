//
//  UIAlertController + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 27.12.2019.
//  Copyright © 2019 Andrew Matsota. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    //MARK: - Classic Alert с одной кнопкой "ОК" c возможностью кастомизировать Tittle&Message
    static func classic (title: String, message: String) -> (UIAlertController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК",  style: .default) {(action) in}
        alertController.addAction(action)
        
        return (alertController)
    }
    
    //MARK: - Classic Alert с одной кнопкой "ОК" БЕЗ возможности кастомизировать Tittle&Message
    static func somethingWrong() -> (UIAlertController){
        let alertController = UIAlertController(title: "Упс!", message: "Что-то пошло не так", preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК",  style: .default) {(action) in}
        alertController.addAction(action)
        
        return (alertController)
    }
    
    //MARK: - Confirm Any Action
    static func confirmAction(message: String, success: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { _ in
            success()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        
        return alert
    }
    
    ///
    //MARK: - Crud
    ///
    
    //MARK: - Success
    //MARK: Half sec
    static func completionDoneHalfSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
    
    //MARK: Two sec
    static func completionDoneTwoSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
    
    //MARK: - Alert Image from URL
    static func confrimAdminCreation(success: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание!", message: "Вы уверенны в том, что хотите создать нового админа? У него будут почти все теже права, что и у Вас. За исключением: 1) Удалять сотрудников; 2) Удалять товары; 3) Удалять заказы, но он сможет их архивировать", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (action: UIAlertAction) in
            success()
        }))
        return alert
    }
    
    //MARK: - Sign in
    static func saveSignIn(_ indicator: UIActivityIndicatorView,success: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Ваши данные для аутентификации будут автоматически сохранены", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { _ in
            success()
        }))
        alert.addAction(UIAlertAction(title: "Отменить вход", style: .destructive, handler: { _ in
            indicator.stopAnimating()
        }))

        return (alert)
    }
    
    //MARK: - Alert Image from URL
    static func uploadImageURL(success: @escaping(String) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Добавить Изображение по Ссылке", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (action: UIAlertAction) in
            let textField = alert.textFields?[0]
            success((textField?.text)!)
        }))
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Введите ссылку"
        }
        return alert
    }
    
    ///
    //MARK: - crUd
    ///
    //MARK: - Password change
    static func updatePassword(_ success: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Подтвердите смену пароля", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { _ in
            success()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        
        return (alert)
    }
    
    //MARK: - Price editor
    static func editProductPrice(name: String, success: @escaping(Int) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Введите новую цену для этого продукта", preferredStyle: .alert)
            
        alert.addTextField { (text:UITextField) in
            text.keyboardType = .numberPad
            text.placeholder = "Введите сообщение"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { (action: UIAlertAction) in
            guard let newPrice = Int((alert.textFields?.first?.text)!)  else {return}
            NetworkManager.shared.editProductPrice(name: name, newPrice: newPrice)
            success(newPrice)
        }))
        return alert
    }
    
    //MARK: - Stock editor
    static func editStockCondition(name: String, stock: Bool, text: UILabel, compltion: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Подтвердите изменение наличия АКЦИИ", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (action: UIAlertAction) in
            NetworkManager.shared.editStockCondition(name: name, stock: stock)
            if stock == true {
                text.text = "Акционный товар"
                text.textColor = .red
            }else{
                text.text = "Акция отсутствует"
                text.textColor = .black
            }
            compltion()
        }))
        return alert
    }
    
    //MARK: - Delivery editor
    static func editDeliveryPerson(success: @escaping(String) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Введите Имя человека, который будет доставлять этот заказ", preferredStyle: .alert)
            
        alert.addTextField { (text:UITextField) in
            text.placeholder = "Введите имя"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { (action: UIAlertAction) in
            guard let deliveryPerson = alert.textFields?.first?.text else {return}
            success(deliveryPerson)
        }))
        return alert
    }
    
    //MARK: - Price editor
    static func setNumber(present message: String, success: @escaping(Int) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
            
        alert.addTextField { (text:UITextField) in
            text.keyboardType = .numberPad
            text.placeholder = "Введите Число"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { (action: UIAlertAction) in
            guard let newNumber = Int((alert.textFields?.first?.text)!)  else {return}
            success(newNumber)
        }))
        return alert
    }
    
    ///
    //MARK: - cruD
    ///
    //MARK: - Sign Out Method
    static func signOut(success: @escaping() -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: "Внимание", message: "Подтвердите, что вы нажали на \"Выход\" неслучайно", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Подтвердить", style: .default, handler: { _ in
            success()
        }))
        return (alert)
    }    

}
