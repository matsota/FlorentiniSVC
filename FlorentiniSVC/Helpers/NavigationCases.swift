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
    enum Transition: String, CaseIterable {
    
        /// ID of View Controllers in Stroryboards
        case LoginVC
        case TabBarVC
        case CatalogListVC
        case ProductManagerVC
        case OrderInProcessVC
        case OrderListVC
        case ChatVC
        case ProfileVC
        case FAQVC
        case EmployeeListVC
        
        /// Cells identifiers
        case OrdersListTVCell
        case OrdersDetailListTVCell
        case CatalogListTVCell
        case ChatTVCell
        case EmloyeeListTVCell
        case FilterTVCell
        case CategoryListTVCell
        
        /// Storyboards
        case Login
        case TabBar
        case CatalogList
        case ProductManager
        case OrderInProcess
        case OrderList
        case orderDetailList
        case Chat
        case Profile
        case StoreStatistics
        case CategoryList
        case EmployeeList
        case FAQ
        case ProductCustomize
        
        /// Segues
        case orderList_OrderDetail
        case catalog_ProductManager
        
    }
    
    //MARK: - First Collection path in Firebase
    enum FirstCollectionRow: String, CaseIterable {
        
        case employee
        case employeeMessages
        case productInfo
        case productImages
        case newOrders
        case inProcessingOrders
        case archivedOrderDescription
        case archivedOrder
        case deletedOrder
        case searchProduct
    
    }
    
    //MARK: - For Employee
    enum EmployeeCases: String, CaseIterable {
        
        case name
        case phone
        case success
        case failure
        case position
        case uid
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
        
    }
    
    //MARK: - For products
    enum ProductCases: String, CaseIterable {
        
        case productName
        case productPrice
        case productQuantity
        case productCategory
        case productSubCategory
        case productDescription
        case productImageURL
        case stock
        case productID
        case searchArray
        case voteCount
        case voteAmount

    }
    
    //MARK: - For Categories
    enum CategorySwitch: String, CaseIterable{
        
        case none = "Выберите категорию"
        case apiece = "Поштучно"
        case gift = "Подарки"
        case bouquet = "Букеты"
        
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
        case orderID
        
    }
    
    //MARK: - Feedback
    enum FeedbackTypesCases: String, CaseIterable {
        
        case cellphone = "По телефону"
        case viber = "Viber"
        case telegram = "Telegram"
        
    }
    
    //MARK: - About quantity
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
    
    //MARK: - About Categories
    enum ProductCategoriesCases: String, CaseIterable {
        
        case allCategories = "Все категории"
        case flower = "Цветы"
        case gift = "Подарки"
        case bouquet = "Букеты"
        case stock = "Акции"
        
    }
    
}


