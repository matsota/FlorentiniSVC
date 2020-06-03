//
//  DatabaseManager.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 19.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    //MARK: - About Employees
    struct EmployeeDataStruct {
        var name: String
        var phone: String
        var position: String
        var uid: String
        var success: Int
        var failure: Int
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.EmployeeCases.name.rawValue: name,
                NavigationCases.EmployeeCases.phone.rawValue: phone,
                NavigationCases.EmployeeCases.position.rawValue: position,
                NavigationCases.EmployeeCases.uid.rawValue: uid,
                NavigationCases.EmployeeCases.success.rawValue: success,
                NavigationCases.EmployeeCases.failure.rawValue: failure
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
//    struct ProductInfo {
//        var productName: String
//        var productPrice: Int
//        var productDescription: String
//        var productCategory: String
//        var stock: Bool
//
//        var dictionary: [String:Any]{
//            return [
//                NavigationCases.ProductCases.productName.rawValue: productName,
//                NavigationCases.ProductCases.productPrice.rawValue: productPrice,
//                NavigationCases.ProductCases.productDescription.rawValue: productDescription,
//                NavigationCases.ProductCases.productCategory.rawValue: productCategory,
//                NavigationCases.ProductCases.stock.rawValue: stock
//            ]
//        }
//    }
    struct ProductInfo {
        var productName: String
        var productPrice: Int
        var productDescription: String
        var productCategory: String
        var stock: Bool
        var productID: String
        var searchArray: [String]
        var voteCount: Int
        var voteAmount: Int
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.ProductCases.productName.rawValue: productName,
                NavigationCases.ProductCases.productPrice.rawValue: productPrice,
                NavigationCases.ProductCases.productDescription.rawValue: productDescription,
                NavigationCases.ProductCases.productCategory.rawValue: productCategory,
                NavigationCases.ProductCases.stock.rawValue: stock,
                NavigationCases.ProductCases.productID.rawValue: productID,
                NavigationCases.ProductCases.searchArray.rawValue: searchArray,
                NavigationCases.ProductCases.voteCount.rawValue: voteCount,
                NavigationCases.ProductCases.voteAmount.rawValue: voteAmount
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
        var currentDeviceID: String
        var deliveryPerson: String
        var orderID: String
        
        var dictionary: [String:Any]{
            return [
                NavigationCases.OrderCases.totalPrice.rawValue: totalPrice,
                NavigationCases.OrderCases.name.rawValue: name,
                NavigationCases.OrderCases.adress.rawValue: adress,
                NavigationCases.OrderCases.cellphone.rawValue: cellphone,
                NavigationCases.OrderCases.feedbackOption.rawValue: feedbackOption,
                NavigationCases.OrderCases.mark.rawValue: mark,
                NavigationCases.OrderCases.timeStamp.rawValue: timeStamp,
                NavigationCases.OrderCases.currentDeviceID.rawValue: currentDeviceID,
                NavigationCases.OrderCases.deliveryPerson.rawValue: deliveryPerson,
                NavigationCases.OrderCases.orderID.rawValue: deliveryPerson
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
extension DatabaseManager.EmployeeDataStruct: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary[NavigationCases.EmployeeCases.name.rawValue] as? String,
            let phone = dictionary[NavigationCases.EmployeeCases.phone.rawValue] as? String,
            let position = dictionary[NavigationCases.EmployeeCases.position.rawValue] as? String,
            let uid = dictionary[NavigationCases.EmployeeCases.uid.rawValue] as? String,
            let success = dictionary[NavigationCases.EmployeeCases.success.rawValue] as? Int,
            let failure = dictionary[NavigationCases.EmployeeCases.failure.rawValue] as? Int else {return nil}
        self.init(name: name, phone: phone, position: position, uid: uid, success: success, failure: failure)
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
//extension DatabaseManager.ProductInfo: DocumentSerializable {
//    init?(dictionary: [String: Any]) {
//        guard let productName = dictionary[NavigationCases.ProductCases.productName.rawValue] as? String,
//            let productPrice = dictionary[NavigationCases.ProductCases.productPrice.rawValue] as? Int,
//            let productDescription = dictionary[NavigationCases.ProductCases.productDescription.rawValue] as? String,
//            let productCategory = dictionary[NavigationCases.ProductCases.productCategory.rawValue] as? String,
//            let stock = dictionary[NavigationCases.ProductCases.stock.rawValue] as? Bool else {return nil}
//        self.init(productName: productName, productPrice: productPrice, productDescription: productDescription, productCategory: productCategory, stock: stock)
//    }
//}

//MARK: Про Продукт
extension DatabaseManager.ProductInfo: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let productName = dictionary[NavigationCases.ProductCases.productName.rawValue] as? String,
            let productPrice = dictionary[NavigationCases.ProductCases.productPrice.rawValue] as? Int,
            let productDescription = dictionary[NavigationCases.ProductCases.productDescription.rawValue] as? String,
            let productCategory = dictionary[NavigationCases.ProductCases.productCategory.rawValue] as? String,
            let stock = dictionary[NavigationCases.ProductCases.stock.rawValue] as? Bool,
            let productID = dictionary[NavigationCases.ProductCases.productID.rawValue] as? String,
            let searchArray = dictionary[NavigationCases.ProductCases.searchArray.rawValue] as? [String],
            let voteCount = dictionary[NavigationCases.ProductCases.voteCount.rawValue] as? Int,
            let voteAmount = dictionary[NavigationCases.ProductCases.voteAmount.rawValue] as? Int else {return nil}
        self.init(productName: productName, productPrice: productPrice, productDescription: productDescription, productCategory: productCategory, stock: stock, productID: productID, searchArray: searchArray, voteCount: voteCount, voteAmount: voteAmount)
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
            let currentDeviceID = dictionary[NavigationCases.OrderCases.currentDeviceID.rawValue] as? String,
            let deliveryPerson = dictionary[NavigationCases.OrderCases.deliveryPerson.rawValue] as? String,
            let orderID = dictionary[NavigationCases.OrderCases.orderID.rawValue] as? String else {return nil}
        self.init(totalPrice: totalPrice, name: userName, adress: userAdress, cellphone: userCellphone, feedbackOption: feedbackOption, mark: userMark, timeStamp: timeStamp, currentDeviceID: currentDeviceID, deliveryPerson: deliveryPerson, orderID: orderID)
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
