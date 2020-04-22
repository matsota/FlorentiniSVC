//
//  DatabaseManager.swift
//  Florentini
//
//  Created by Andrew Matsota on 19.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    //MARK: - About Employees
    struct EmployeeData {
        var name: String
        var position: String
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.EmployeeCases.name.rawValue: name,
                NavigationCases.EmployeeCases.position.rawValue: position
            ]
        }
    }
    
    //MARK: - For Chat
    struct ChatMessages {
        var name: String
        var content: String
        var position: String
        var uid: String
        var timeStamp: Date
        
        var dictionary: [String:Any] {
            return [
                NavigationCases.MessagesCases.name.rawValue: name,
                NavigationCases.MessagesCases.content.rawValue: content,
                NavigationCases.EmployeeCases.position.rawValue: position,
                NavigationCases.MessagesCases.uid.rawValue: uid,
                NavigationCases.MessagesCases.timeStamp.rawValue: timeStamp
            ]
        }
    }
    
    //MARK: - About Product
    struct ProductInfo {
        var productName: String
        var productPrice: Int
        var productDescription: String
        var productCategory: String
        var stock: Bool
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.ProductCases.productName.rawValue: productName,
                NavigationCases.ProductCases.productPrice.rawValue: productPrice,
                NavigationCases.ProductCases.productDescription.rawValue: productDescription,
                NavigationCases.ProductCases.productCategory.rawValue: productCategory,
                NavigationCases.ProductCases.stock.rawValue: stock
            ]
        }
    }
    
    //MARK: - Шаблон Про Заказ
    struct Order {
        var totalPrice: Int64
        var name: String
        var adress: String
        var cellphone: String
        var feedbackOption: String
        var mark: String
        var timeStamp: Date
        var orderID: String
        var deliveryPerson: String
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.OrderCases.totalPrice.rawValue: totalPrice,
                NavigationCases.OrderCases.name.rawValue: name,
                NavigationCases.OrderCases.adress.rawValue: adress,
                NavigationCases.OrderCases.cellphone.rawValue: cellphone,
                NavigationCases.OrderCases.feedbackOption.rawValue: feedbackOption,
                NavigationCases.OrderCases.mark.rawValue: mark,
                NavigationCases.OrderCases.timeStamp.rawValue: timeStamp,
                NavigationCases.OrderCases.currentDeviceID.rawValue: orderID,
                NavigationCases.OrderCases.deliveryPerson.rawValue: deliveryPerson
            ]
        }
    }
    
    //MARK: Про детализацию заказа
    struct OrderAddition {
        var productCategory: String
        var productName: String
        var stock: Bool
        var productPrice: Int
        var productQuantity: Int

        var dictionary: [String:Any]{
            return [
                NavigationCases.ProductCases.productCategory.rawValue: productCategory,
                NavigationCases.ProductCases.productName.rawValue: productName,
                NavigationCases.ProductCases.stock.rawValue: stock,
                NavigationCases.ProductCases.productPrice.rawValue: productPrice,
                NavigationCases.ProductCases.productQuantity.rawValue: productQuantity
            ]
        }
    }
    
}

//MARK: - OUT of Class
//MARK: - Протокол шаблонов
protocol DocumentSerializable {
    init?(dictionary: [String:Any])
}


//MARK: - Extensions Init

//MARK: Employee
extension DatabaseManager.EmployeeData: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary[NavigationCases.EmployeeCases.name.rawValue] as? String,
            let position = dictionary[NavigationCases.EmployeeCases.position.rawValue] as? String else {return nil}
        self.init(name: name, position: position)
    }
}

//MARK: Про чат
extension DatabaseManager.ChatMessages: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary[NavigationCases.MessagesCases.name.rawValue] as? String,
            let content = dictionary[NavigationCases.MessagesCases.content.rawValue] as? String,
            let position = dictionary[NavigationCases.EmployeeCases.position.rawValue] as? String,
            let uid = dictionary[NavigationCases.MessagesCases.uid.rawValue] as? String,
            let timeStamp = (dictionary[NavigationCases.MessagesCases.timeStamp.rawValue] as? Timestamp)?.dateValue() else {return nil}
        self.init(name: name, content: content, position: position, uid: uid, timeStamp: timeStamp)
    }
}

//MARK: Про Продукт
extension DatabaseManager.ProductInfo: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let productName = dictionary[NavigationCases.ProductCases.productName.rawValue] as? String,
            let productPrice = dictionary[NavigationCases.ProductCases.productPrice.rawValue] as? Int,
            let productDescription = dictionary[NavigationCases.ProductCases.productDescription.rawValue] as? String,
            let productCategory = dictionary[NavigationCases.ProductCases.productCategory.rawValue] as? String,
            let stock = dictionary[NavigationCases.ProductCases.stock.rawValue] as? Bool else {return nil}
        self.init(productName: productName, productPrice: productPrice, productDescription: productDescription, productCategory: productCategory, stock: stock)
    }
}

//MARK: Про Заказ
extension DatabaseManager.Order: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let totalPrice = dictionary[NavigationCases.OrderCases.totalPrice.rawValue] as? Int64,
            let userName = dictionary[NavigationCases.OrderCases.name.rawValue] as? String,
            let userAdress = dictionary[NavigationCases.OrderCases.adress.rawValue] as? String,
            let userCellphone = dictionary[NavigationCases.OrderCases.cellphone.rawValue] as? String,
            let feedbackOption = dictionary[NavigationCases.OrderCases.feedbackOption.rawValue] as? String,
            let userMark = dictionary[NavigationCases.OrderCases.mark.rawValue] as? String,
            let timeStamp = (dictionary[NavigationCases.OrderCases.timeStamp.rawValue] as? Timestamp)?.dateValue(),
            let orderID = dictionary[NavigationCases.OrderCases.currentDeviceID.rawValue] as? String,
        let deliveryPerson = dictionary[NavigationCases.OrderCases.deliveryPerson.rawValue] as? String else {return nil}
        self.init(totalPrice: totalPrice, name: userName, adress: userAdress, cellphone: userCellphone, feedbackOption: feedbackOption, mark: userMark, timeStamp: timeStamp, orderID: orderID, deliveryPerson: deliveryPerson)
    }
}

//MARK: Про детализацию заказа
extension DatabaseManager.OrderAddition: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let productCategory = dictionary[NavigationCases.ProductCases.productCategory.rawValue] as? String,
            let productName = dictionary[NavigationCases.ProductCases.productName.rawValue] as? String,
            let stock = dictionary[NavigationCases.ProductCases.stock.rawValue] as? Bool,
            let productPrice = dictionary[NavigationCases.ProductCases.productPrice.rawValue] as? Int,
            let productQuantity = dictionary[NavigationCases.ProductCases.productQuantity.rawValue] as? Int else {return nil}
        self.init(productCategory: productCategory, productName: productName, stock: stock, productPrice: productPrice, productQuantity: productQuantity)
    }
}
