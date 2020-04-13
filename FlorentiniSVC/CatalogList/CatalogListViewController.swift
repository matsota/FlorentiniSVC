//
//  CatalogListViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseUI

class CatalogListViewController: UIViewController {
    
    //MARK: - Override
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forViewDidLoad()
        
    }
    
    //MARK: - Transition menu tapped
    @IBAction private func transitionMenuTapped(_ sender: UIButton) {
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
    @IBAction private func transitionDismissTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
    }
    
    
    //MARK: - Product filter Start
    @IBAction private func startFiltering(_ sender: DesignButton) {
        guard let sender = sender.titleLabel!.text else {return}
        showOptionsMethod(option: sender)
    }
    
    //MARK: - Product dilter End
    @IBAction private func endFiltering(_ sender: DesignButton) {
        selectionMethod(self, sender)
    }
    
    //MARK: - Private Implementation
    private var productInfo = [DatabaseManager.ProductInfo]()
    private var employeePosition: String?
    private var selectedCategory = String()
    
    //MARK: View
    @IBOutlet private weak var buttonsView: UIView!
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: TableView Outlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Button
    @IBOutlet private var allFilterButtonsCollection: [DesignButton]!
    @IBOutlet private weak var filterButton: DesignButton!
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    //MARK: Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
    
}








//MARK: - Extention:

//MARK: - For Overrides
private extension CatalogListViewController {
    
    //MARK: for  ViewDidLoad
    func forViewDidLoad() {
//        transitionViewLeftConstraint.constant = -UIScreen.main.bounds.width * 0.65
        
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
        
        NetworkManager.shared.downloadProducts(success: { productInfo in
            self.productInfo = productInfo
            self.tableView.reloadData()
        }) { error in
            print(error.localizedDescription)
        }
        
        NetworkManager.shared.downloadEmployeeInfo(success: { (data) in
            self.employeePosition = data.map({$0.position}).first
        }) { error in
            print(error.localizedDescription)
        }
    }
    
}

//MARK: - TableView Extention
extension CatalogListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.CatalogListTVCell.rawValue, for: indexPath) as! CatalogListTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        let fetch = productInfo[cell.tag],
        name = fetch.productName,
        price = fetch.productPrice,
        category = fetch.productCategory,
        description = fetch.productDescription,
        stock = fetch.stock,
        storagePath = "\(NavigationCases.ProductCases.imageCollection.rawValue)/\(name)",
        storageRef = Storage.storage().reference(withPath: storagePath)
        
        
        cell.imageActivityIndicator.isHidden = false
        cell.imageActivityIndicator.startAnimating()
        
        cell.fill(name: name, price: price, category: category, description: description, stock: stock, image: { (image) in
            DispatchQueue.main.async {
                image.sd_setImage(with: storageRef)
                cell.imageActivityIndicator.isHidden = true
                cell.imageActivityIndicator.stopAnimating()
            }
        }) { (error) in
            cell.imageActivityIndicator.isHidden = true
            cell.imageActivityIndicator.stopAnimating()
            print(error.localizedDescription)
        }
        return cell
    }
    
    //MARK: Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let position = self.employeePosition else {return nil}
        if position == "admin" {
            let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.CatalogListTVCell.rawValue, for: indexPath) as! CatalogListTableViewCell
            guard let name = cell.productNameLabel.text else {return nil}
            let delete = deleteAction(name: name, at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete])
        }
        return nil
    }
    
    func deleteAction(name: String, at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            if AuthenticationManager.shared.currentUser?.uid == AuthenticationManager.shared.uidAdmin {
                self.present(UIAlertController.productDelete(name: name, success: {
                    self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Продукт удачно Удалён"), animated: true)
                    self.productInfo.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }), animated: true)
                complition(true)
            }else{
                self.present(UIAlertController.classic(title: "Эттеншн", message: "У Вас нет прав Администратора, чтобы удалять любую из позиций. Не ну ты ЧО"), animated: true)
                complition(false)
            }
        }
        action.backgroundColor = .red
        return action
    }
    
}

//MARK: Методы TableViewCell через delegate
extension CatalogListViewController: CatalogListTableViewCellDelegate {
    
    func editPrice(_ cell: CatalogListTableViewCell){
        guard let name = cell.productNameLabel.text else {return}
        
        if AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid {
            cell.productPriceButton.isUserInteractionEnabled = true
            
            self.present(UIAlertController.editProductPrice(name: name, success: { newPrice in
                cell.productPriceButton.setTitle("\(newPrice) грн", for: .normal)
            }),animated: true)
        }else{
            cell.productPriceButton.isUserInteractionEnabled = false
        }
        self.tableView.reloadData()
    }
    
    func editStockCondition(_ cell: CatalogListTableViewCell, _ text: UILabel) {
        
        guard let name = cell.productNameLabel.text else {return}
        
        if cell.stockSwitch.isOn == true {
            self.present(UIAlertController.editStockCondition(name: name, stock: true, text: text) {
                if self.selectedCategory != "" {
                    self.productInfo.remove(at: cell.tag)
                    self.tableView.reloadData()
                }
            }, animated: true)
        }else{
            
            self.present(UIAlertController.editStockCondition(name: name, stock: false, text: text) {
                if self.selectedCategory == NavigationCases.ProductCategoriesCases.stock.rawValue {
                    self.productInfo.remove(at: cell.tag)
                    self.tableView.reloadData()
                }
            }, animated: true)
        }
    }
    
}

//MARK: - Появление вариантов Категорий для отфильтровывания продукции
private extension CatalogListViewController {
    func showOptionsMethod(option: String) {
        selectedCategory = option
        allFilterButtonsCollection.forEach { (buttons) in
            if buttons.isHidden == true {
                UIView.animate(withDuration: 0.2) {
                    buttons.isHidden = false
                    self.filterButton.isHidden = !self.buttonsView.isHidden
                    self.buttonsView.layoutIfNeeded()
                }
            }else{
                UIView.animate(withDuration: 0.2) {
                    buttons.isHidden = true
                    self.buttonsView.layoutIfNeeded()
                }
            }
            filterButton.setTitle(option, for: .normal)
        }
    }
}

//MARK: - Метод фильтрации продукции по категориям
private extension CatalogListViewController {
    
    func selectionMethod(_ class: UIViewController, _ sender: UIButton) {
        guard let title = sender.currentTitle, let categories = NavigationCases.ProductCategoriesCases(rawValue: title) else {return}
        switch categories {
        case .apiece:
            showOptionsMethod(option: NavigationCases.ProductCategoriesCases.apiece.rawValue)
            NetworkManager.shared.downloadApieces(success: { productInfo in
                self.productInfo = productInfo
                self.filterButton.isHidden = false
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
        case .gift:
            showOptionsMethod(option: NavigationCases.ProductCategoriesCases.gift.rawValue)
            NetworkManager.shared.downloadGifts(success: { productInfo in
                self.productInfo = productInfo
                self.filterButton.isHidden = false
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
        case .bouquet:
            showOptionsMethod(option: NavigationCases.ProductCategoriesCases.bouquet.rawValue)
            NetworkManager.shared.downloadBouquets(success: { productInfo in
                self.productInfo = productInfo
                self.filterButton.isHidden = false
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
        case .stock:
            showOptionsMethod(option: NavigationCases.ProductCategoriesCases.stock.rawValue)
            NetworkManager.shared.downloadStocks(success: { productInfo in
                self.productInfo = productInfo
                self.filterButton.isHidden = false
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
        }
    }
    
}

