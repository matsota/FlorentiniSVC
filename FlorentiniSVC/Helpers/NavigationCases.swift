//
//  NavigationCases.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation

class NavigationCases {
    
    //MARK: -
    
    //MARK: - For VCs
    enum IDVC: String, CaseIterable {
        
        // - VC
        case LoginVC
        case TransitionMenuVC
        case OrderListVC
        case CatalogListVC
        case ProfileVC
        case FAQVC
        case ChatVC
        
        // - Cells
        case OrdersListTVCell
        case OrdersDetailListTVCell
        case CatalogListTVCell
        case ChatTVCell
        
        
        // - sugue
    }
    
    //MARK: - For Employee
    enum EmployeeCases: String, CaseIterable {
        
        case name
        case position
        case admin
        case `operator`
        case delivery
        
    }
    
    //MARK: - For Notifications
    enum Notification: String, CaseIterable {
        
        case newMessage
        
    }
    
    //MARK: - Fow messages
    enum MessagesCases: String, CaseIterable {
        
        case name
        case content
        case uid
        case timeStamp
        case workers
        case workersMessages
//        case review
        
    }
    
    //MARK: - For products
    enum ProductCases: String, CaseIterable {
        
        case productName
        case productPrice
        case productQuantity
        case productCategory
        case productDescription
        case productImageURL
        case imageCollection
        case stock
        
    }
    
    //MARK: - For Categories
    enum CategorySwitch: String, CaseIterable{
        
        case none = "Без Категории"
        case apiece = "Поштучно"
        case gift = "Подарки"
        case bouquet = "Букеты"
        
    }
    
    //MARK: - For Archive
    enum ArchiveCases: String, CaseIterable{
        
        case archivedOrders
        case archivedOrderAdditions
        case deletedOrders
        
    }
    
    //MARK: - For transition menu
    
    enum TranstionCases: String, CaseIterable {
        
        case homeScreen = "Главная"
        case catalogScreen = "Каталог"
        case profile = "Профиль"
        case faqScreen = "FAQ"
        case exit = "Exit"
        
    }
    
    //MARK: - About Order
    enum OrderCases: String, CaseIterable {
        case order
        case orderDescription
        
        case totalPrice
        case name
        case adress
        case cellphone
        case feedbackOption
        case mark
        case timeStamp
        case currentDeviceID
        case deliveryPerson
        
    }
    
    //MARK: - Про обратную связь
    enum FeedbackTypesCases: String, CaseIterable {
        
        case cellphone = "По телефону"
        case viber = "Viber"
        case telegram = "Telegram"
        
    }
    
    //MARK: - Про количество
    enum MaxQuantityByCategoriesCases: Int {
        
        case towHundred = 200
        //        case hundredAndHalf = 150
        case hundred = 100
        //        case halfHundred = 50
        case five = 5
        case three = 3
        
    }
    
    //MARK: - For price increase/decrease
    enum MinusPlus : String, CaseIterable {
        case minus = "-"
        case plus = "+"
    }
    
    //MARK: - Про Категории
    enum ProductCategoriesCases: String, CaseIterable {
        
        case apiece = "Поштучно"
        case gift = "Подарки"
        case bouquet = "Букеты"
        case stock = "Акции"
        
    }
    
}


