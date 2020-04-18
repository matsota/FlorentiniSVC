//
//  StoreStaticticViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 05.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class StoreStaticticViewController: UIViewController {
    
    //MARK: - Overrides
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forViewDidLoad()
        
    }
    
    //MARK: - Transition menu tapped
    @IBAction func transitionMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
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
    @IBAction func transitionDismiss(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
    }
    
    //MARK: - Quantity of receipt for regular customer. Default = 5
    @IBAction private func regularCusmotersTapped(_ sender: UIButton) {
        self.present(UIAlertController.setNumber(present:"Введите минимальное число чеков для Постоянного покупателя", success: { (number) in
            self.receiptsCountOfRegularCustomers = number
            self.regularCusmotersButton.setTitle("Постоянные Клиенты (больше \(self.receiptsCountOfRegularCustomers) покупок)", for: .normal)
            self.viewDidLoad()
        }), animated: true)
    }
    //MARK: - By product frequency
    @IBAction private func byFrequencyTapped(_ sender: UIButton) {
        hideUnhideFrequency()
    }
    
    //MARK: - By receipts
    @IBAction private func byReceiptsTapped(_ sender: UIButton) {
        hideUnhideReceipts()
    }
    
    //MARK: Statistics by receipts amount
    // - Default = 3000
    @IBAction private func receiptsOverSomePriceTapped(_ sender: UIButton) {
        self.present(UIAlertController.setNumber(present: "Введите сумму покупки, и вам покажет количество чеков, сумма которых БОЛЬШЕ введённой цифры", success: { (number) in
            self.overSomePrice = number
            self.receiptsOverSomePriceButton.setTitle("Чеков на сумму > \(number) грн", for: .normal)
            self.viewDidLoad()
        }), animated: true)
    }
    // - Default = 700
    @IBAction private func receiptsLessSomePriceTapped(_ sender: UIButton) {
        self.present(UIAlertController.setNumber(present: "Введите сумму покупки, и вам покажет количество чеков, сумма которых МЕНЬШЕ введённой цифры", success: { (number) in
            self.lessSomePrice = number
            self.receiptsLessSomePriceButton.setTitle("Чеков на сумму < \(number) грн", for: .normal)
            self.viewDidLoad()
        }), animated: true)
    }
    
    //MARK: - By popularity
    @IBAction private func byPopularityTapped(_ sender: UIButton) {
        hideUnhidePopularity()
    }
    
    
    //MARK: - Implementation
    private var receiptsCountOfRegularCustomers = 5
    private var overSomePrice = 3000
    private var lessSomePrice = 700
    
    //MARK: - Labels
    @IBOutlet private weak var totalAmountLabel: UILabel!
    @IBOutlet private weak var totalOrdersLabel: UILabel!
    
    @IBOutlet private weak var ordersCompletedLabel: UILabel!
    @IBOutlet private weak var ordersCompletedPercentageLabel: UILabel!
    
    @IBOutlet private weak var ordersFailedLabel: UILabel!
    @IBOutlet private weak var ordersFailedPercentageLabel: UILabel!
    
    @IBOutlet private weak var uniqueCustomersLabel: UILabel!
    
    @IBOutlet private weak var regularCustomersLabel: UILabel!
    @IBOutlet private weak var regularCustomersPercentageLabel: UILabel!
    
    @IBOutlet private weak var bouquetFrequencyLabel: UILabel!
    @IBOutlet private weak var bouquetFrequencyPercentageLabel: UILabel!
    @IBOutlet private weak var amountOfBouquetsLabel: UILabel!
    @IBOutlet private weak var amountOfBouquetsPercentageLabel: UILabel!
    
    @IBOutlet private weak var flowerFrequencyLabel: UILabel!
    @IBOutlet private weak var flowerFrequencyPercentageLabel: UILabel!
    @IBOutlet private weak var amountOfFlowersLabel: UILabel!
    @IBOutlet private weak var amountOfFlowersPercentageLabel: UILabel!
    
    @IBOutlet private weak var giftFrequencyLabel: UILabel!
    @IBOutlet private weak var giftFrequencyPercentageLabel: UILabel!
    @IBOutlet private weak var amountOfGiftsLabel: UILabel!
    @IBOutlet private weak var amountOfGiftsPercentageLabel: UILabel!
    
    @IBOutlet private weak var stockFrequencyLabel: UILabel!
    @IBOutlet private weak var stockFrequencyPercentageLabel: UILabel!
    @IBOutlet private weak var amountOfStocksLabel: UILabel!
    @IBOutlet private weak var amountOfStocksPercentageLabel: UILabel!
    
    
    @IBOutlet private weak var overSomePriceLabel: UILabel!
    @IBOutlet private weak var lessSomePriceLabel: UILabel!
    @IBOutlet private weak var maxReceiptLabel: UILabel!
    @IBOutlet private weak var averageReceiptLabel: UILabel!
    @IBOutlet private weak var minReceiptLabel: UILabel!
    
    @IBOutlet private weak var mostPopularProductLabel: UILabel!
    @IBOutlet private weak var lessPopularProductLabel: UILabel!
    
    @IBOutlet private weak var mostPopularBouquetLabel: UILabel!
    @IBOutlet private weak var lessPopularBouquetLabel: UILabel!
    
    @IBOutlet private weak var mostPopularFlowerLabel: UILabel!
    @IBOutlet private weak var lessPopularFlowerLabel: UILabel!
    
    @IBOutlet private weak var mostPopularGiftLabel: UILabel!
    @IBOutlet private weak var lessPopularGiftLabel: UILabel!
    
    
    //MARK: - Stack View
    //MARK: Frequency
    @IBOutlet private weak var bouquetFrequencyStackView: UIStackView!
    @IBOutlet private weak var flowerFrequencyStackView: UIStackView!
    @IBOutlet private weak var giftFrequencyStackView: UIStackView!
    @IBOutlet private weak var stockFrequencyStackView: UIStackView!
    //MARK: Receipts
    @IBOutlet private weak var receiptOverSomePriceStackView: UIStackView!
    @IBOutlet private weak var receiptLessSomePriceStackView: UIStackView!
    @IBOutlet private weak var maxReceiptStackView: UIStackView!
    @IBOutlet private weak var averageReceiptStackView: UIStackView!
    @IBOutlet private weak var minReceiptStackView: UIStackView!
    //MARK: Popularity
    @IBOutlet private weak var mostPopularProductStackView: UIStackView!
    @IBOutlet private weak var lessPopularProductStackView: UIStackView!
    @IBOutlet private weak var mostPopularBouquetStackView: UIStackView!
    @IBOutlet private weak var lessPopularBouquetStackView: UIStackView!
    @IBOutlet private weak var mostPopularFlowerStackView: UIStackView!
    @IBOutlet private weak var lessPopularFlowerStackView: UIStackView!
    @IBOutlet private weak var mostPopularGiftStackView: UIStackView!
    @IBOutlet private weak var lessPopularGiftStackView: UIStackView!
    
    
    //MARK: Button
    @IBOutlet private weak var regularCusmotersButton: UIButton!
    @IBOutlet private weak var receiptsOverSomePriceButton: UIButton!
    @IBOutlet private weak var receiptsLessSomePriceButton: UIButton!
    @IBOutlet weak var transitionDismissButton: UIButton!
    
    //MARK: View
    @IBOutlet weak var transitionView: UIView!
    
    //MARK: Constraint
    @IBOutlet weak var transitionViewLeftConstraint: NSLayoutConstraint!
    
}









//MARK: - Extensions:

//MARK: - For Overrides
private extension StoreStaticticViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {
        NetworkManager.shared.fetchArchivedOrders(success: { (receipts, additions, deletedData)  in
            //Total Amount
            self.forStatsByTotalAmount(additions: additions)
            
            //Orders total, completed, deleted
            self.forStatsByOrders(receipts: receipts, deletedData: deletedData)
            
            //Customers
            self.forStatsByCustomers(receipts: receipts)
            
            //for Receipts
            NetworkManager.shared.fetchArchivedOrdersByReceipts(overThan: self.overSomePrice, lessThan: self.lessSomePrice, success: { (over, less)  in
                self.forStatsByReceipts(receipts: receipts, over: over, less: less)
            }) { (error) in
                print("Error occured in fetchArchivedOrdersByReceipts",error.localizedDescription)
            }
            
            //Most/Less popular product
            self.mostPopularProductLabel.text = self.forStatsByMostPopular(additions: additions)
            self.lessPopularProductLabel.text = self.forStatsByLessPopular(additions: additions)
        }) { (error) in
            print("Error occured in fetchArchivedOrders",error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Данные не подтягиваются из сети"), animated: true)
        }
        
        //Based on category
        NetworkManager.shared.fetchArchivedOrdersByCategory(success: { (bouquetData, apeiceData, giftData, stockData) in
            // - By Frequency
            self.forStatsByCategoryFrequency(bouquetData: bouquetData, apeiceData: apeiceData, giftData: giftData, stockData: stockData)
            
            // - By Populariy
            self.forStatsByPopular(bouquetData: bouquetData, apeiceData: apeiceData, giftData: giftData)
            
        }) { (error) in
            print("Error occured in fetchArchivedOrdersByCategory",error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Данные не подтягиваются из сети"), animated: true)
        }
    }
    
}

//MARK: - Statistics
private extension StoreStaticticViewController{
    
    //MARK: По Общему обороту
    func forStatsByTotalAmount(additions: [DatabaseManager.OrderAddition]) {
        let totalAmount = additions.map({$0.productPrice * $0.productQuantity}).reduce(0, +)
        self.totalAmountLabel.text = "\(totalAmount) грн"
    }
    
    //MARK: По Заказам
    func forStatsByOrders(receipts: [DatabaseManager.Order], deletedData: [DatabaseManager.Order]) {
        let ordersCompleted = receipts.count,
        ordersFailed = deletedData.count,
        totalOrders = ordersCompleted + ordersFailed,
        ordersCompletedPersentage = Int(Float(ordersCompleted)/Float(totalOrders) * 100.0),
        ordersFailedPersentage = Int(Float(ordersFailed)/Float(totalOrders) * 100.0)
        
        // - total
        self.totalOrdersLabel.text = "\(totalOrders)"
        
        // - completed
        self.ordersCompletedLabel.text = "\(ordersCompleted)"
        self.ordersCompletedPercentageLabel.text = "\(ordersCompletedPersentage)"
        
        // - deleted
        self.ordersFailedLabel.text = "\(ordersFailed)"
        self.ordersFailedPercentageLabel.text = "\(ordersFailedPersentage)"
    }
    
    //MARK: By Customers
    func forStatsByCustomers(receipts: [DatabaseManager.Order]) {
        let uniqueCustomers = Set(receipts.map({$0.orderID})),
        uniqueCustomersQuantity = uniqueCustomers.count
        self.uniqueCustomersLabel.text = "\(uniqueCustomersQuantity)"
        
        // - regular customers
        var allCustomers = String(),
        regularCustomersQuantity = Int()
        
        for i in receipts {
            allCustomers += "(\(i.orderID)), "
        }
        
        for i in uniqueCustomers {
            if allCustomers.countCertainString(string: i.lowercased()) > self.receiptsCountOfRegularCustomers {
                regularCustomersQuantity += 1
            }
        }
        
        let regularCustumersPersentage = Int(Float(regularCustomersQuantity)/Float(uniqueCustomersQuantity) * 100.0)
        self.regularCustomersLabel.text = "\(regularCustomersQuantity)"
        self.regularCustomersPercentageLabel.text = "\(regularCustumersPersentage)"
    }
    
    //MARK: По Чекам
    func forStatsByReceipts(receipts: [DatabaseManager.Order], over: [DatabaseManager.Order], less: [DatabaseManager.Order]) {
        var allTotalPricesArray = receipts.map({$0.totalPrice})
        allTotalPricesArray.sort()
        
        let biggerThan = over.count,
        lessThan = less.count,
        average = Int(allTotalPricesArray.reduce(0, +))/allTotalPricesArray.count
        
        guard let max = allTotalPricesArray.last, let min = allTotalPricesArray.first else {return}
        
        self.maxReceiptLabel.text = "\(max)"
        self.averageReceiptLabel.text = "\(average)"
        self.minReceiptLabel.text = "\(min)"
        self.overSomePriceLabel.text = "\(biggerThan)"
        self.lessSomePriceLabel.text = "\(lessThan)"
    }
    
    //MARK: By Frequency in categories
    func forStatsByCategoryFrequency(bouquetData: [DatabaseManager.OrderAddition], apeiceData: [DatabaseManager.OrderAddition], giftData: [DatabaseManager.OrderAddition], stockData: [DatabaseManager.OrderAddition]) {
        
        let bouquets = bouquetData.count,
        apeices = apeiceData.count,
        gifts = giftData.count,
        stocks = stockData.count,
        total = bouquets + apeices + gifts,
        bouquetPercentage = Int(Double(bouquets)/Double(total) * 100.0),
        apeicePercentage = Int(Double(apeices)/Double(total) * 100.0),
        giftPercentage = Int(Double(gifts)/Double(total) * 100.0),
        stockPercentage = Int(Double(stocks)/Double(total) * 100.0),
        bouquetAmount = bouquetData.map({$0.productPrice * $0.productQuantity}).reduce(0, +),
        apeiceAmount = apeiceData.map({$0.productPrice * $0.productQuantity}).reduce(0, +),
        giftAmount = giftData.map({$0.productPrice * $0.productQuantity}).reduce(0, +),
        stockAmount = stockData.map({$0.productPrice * $0.productQuantity}).reduce(0, +),
        totalAmount = bouquetAmount + apeiceAmount + giftAmount,
        bouquetAmountPercentage = Int(Double(bouquetAmount)/Double(totalAmount) * 100.0),
        apeiceAmountPercentage = Int(Double(apeiceAmount)/Double(totalAmount) * 100.0),
        giftAmountPercentage = Int(Double(giftAmount)/Double(totalAmount) * 100.0),
        stockAmountPercentage = Int(Double(stockAmount)/Double(totalAmount) * 100.0)
        
        // - bouquets
        self.bouquetFrequencyLabel.text = "\(bouquets)"
        self.bouquetFrequencyPercentageLabel.text = "\(bouquetPercentage)"
        self.amountOfBouquetsLabel.text = "\(bouquetAmount)"
        self.amountOfBouquetsPercentageLabel.text = "\(bouquetAmountPercentage)"
        // - apieces
        self.flowerFrequencyLabel.text = "\(apeices)"
        self.flowerFrequencyPercentageLabel.text = "\(apeicePercentage)"
        self.amountOfFlowersLabel.text = "\(apeiceAmount)"
        self.amountOfFlowersPercentageLabel.text = "\(apeiceAmountPercentage)"
        // - gifts
        self.giftFrequencyLabel.text = "\(gifts)"
        self.giftFrequencyPercentageLabel.text = "\(giftPercentage)"
        self.amountOfGiftsLabel.text = "\(giftAmount)"
        self.amountOfGiftsPercentageLabel.text = "\(giftAmountPercentage)"
        // - stocks
        self.stockFrequencyLabel.text = "\(stocks)"
        self.stockFrequencyPercentageLabel.text = "\(stockPercentage)"
        self.amountOfStocksLabel.text = "\(stockAmount)"
        self.amountOfStocksPercentageLabel.text = "\(stockAmountPercentage)"
    }
    
    //MARK: Prepare-1 for 'By populariy'
    func forStatsByMostPopular(additions: [DatabaseManager.OrderAddition]) -> String {
        
        var nameCountDict = [String: Int](),
        array = [String]()
        
        for i in additions {
            array.append(i.productName)
        }
        
        for name in array {
            if let count = nameCountDict[name] {
                nameCountDict[name] = count + 1
            }else{
                nameCountDict[name] = 1
            }
        }
        
        var mostPopularProduct = ""
        
        for key in nameCountDict.keys {
            if mostPopularProduct == "" {
                mostPopularProduct = key
            }else{
                let count = nameCountDict[key]
                if count! > nameCountDict[mostPopularProduct]! {
                    mostPopularProduct = key
                }
            }
        }
        return mostPopularProduct
    }
    
    //MARK: Prepare-2 for 'By populariy'
    func forStatsByLessPopular(additions: [DatabaseManager.OrderAddition]) -> String {
        
        var nameCountDict = [String: Int](),
        array = [String]()
        
        for i in additions {
            array.append(i.productName)
        }
        
        for name in array {
            if let count = nameCountDict[name] {
                nameCountDict[name] = count + 1
            }else{
                nameCountDict[name] = 1
            }
        }
        
        var mostPopularProduct = ""
        
        for key in nameCountDict.keys {
            if mostPopularProduct == "" {
                mostPopularProduct = key
            }else{
                let count = nameCountDict[key]
                if count! < nameCountDict[mostPopularProduct]! {
                    mostPopularProduct = key
                }
            }
        }
        return mostPopularProduct
    }
    
    //MARK: - By populariy
    func forStatsByPopular (bouquetData: [DatabaseManager.OrderAddition], apeiceData: [DatabaseManager.OrderAddition], giftData: [DatabaseManager.OrderAddition]) {
        //Bouquet
        self.mostPopularBouquetLabel.text = self.forStatsByMostPopular(additions: bouquetData)
        self.lessPopularBouquetLabel.text = self.forStatsByLessPopular(additions: bouquetData)
        //Flower
        self.mostPopularFlowerLabel.text = self.forStatsByMostPopular(additions: apeiceData)
        self.lessPopularFlowerLabel.text = self.forStatsByLessPopular(additions: apeiceData)
        //Gift
        self.mostPopularGiftLabel.text = self.forStatsByMostPopular(additions: giftData)
        self.lessPopularGiftLabel.text = self.forStatsByLessPopular(additions: giftData)
        
        if self.mostPopularGiftLabel == nil {
            
        }
    }
    
    
    
}

//MARK: - Hide-Unhide certain statistics
private extension StoreStaticticViewController {

    func hideUnhideFrequency() {
        UIView.animate(withDuration: 0.3) {
            self.bouquetFrequencyStackView.isHidden = !self.bouquetFrequencyStackView.isHidden
            self.flowerFrequencyStackView.isHidden = !self.flowerFrequencyStackView.isHidden
            self.giftFrequencyStackView.isHidden = !self.giftFrequencyStackView.isHidden
            self.stockFrequencyStackView.isHidden = !self.stockFrequencyStackView.isHidden
            self.view.layoutIfNeeded()
        }
    }
    
    func hideUnhideReceipts() {
        UIView.animate(withDuration: 0.3) {
            self.receiptOverSomePriceStackView.isHidden = !self.receiptOverSomePriceStackView.isHidden
            self.receiptLessSomePriceStackView.isHidden = !self.receiptLessSomePriceStackView.isHidden
            self.maxReceiptStackView.isHidden = !self.maxReceiptStackView.isHidden
            self.averageReceiptStackView.isHidden = !self.averageReceiptStackView.isHidden
            self.minReceiptStackView.isHidden = !self.minReceiptStackView.isHidden
            self.view.layoutIfNeeded()
        }
    }
    
    func hideUnhidePopularity() {
        UIView.animate(withDuration: 0.3) {
            self.mostPopularProductStackView.isHidden = !self.mostPopularProductStackView.isHidden
            self.lessPopularProductStackView.isHidden = !self.lessPopularProductStackView.isHidden
            self.mostPopularBouquetStackView.isHidden = !self.mostPopularBouquetStackView.isHidden
            self.lessPopularBouquetStackView.isHidden = !self.lessPopularBouquetStackView.isHidden
            self.mostPopularFlowerStackView.isHidden = !self.mostPopularFlowerStackView.isHidden
            self.lessPopularFlowerStackView.isHidden = !self.lessPopularFlowerStackView.isHidden
            self.mostPopularGiftStackView.isHidden = !self.mostPopularGiftStackView.isHidden
            self.lessPopularGiftStackView.isHidden = !self.lessPopularGiftStackView.isHidden
            self.view.layoutIfNeeded()
        }
    }
    
}
