//
//  CatalogListViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

struct filterTVStruct {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class CatalogListViewController: UIViewController {
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        forViewDidLoad()
    }
    
    @IBAction func filterTapped(_ sender: UIButton) {
        filterTableViewAppearceConstraint.constant = hideUnhideFilter()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Edit price by category
    @IBAction func editPricesByCategoryTapped(_ sender: UIButton) {
        editPricesByCategory(sender)
    }
    
    
    //MARK: - Private Implementation
    private var productInfo = [DatabaseManager.ProductInfo]()
    private var filterData = [filterTVStruct]()
    private var employeePosition: String?
    private var selectedCategory: String?
    
    
    //MARK: TableView
    @IBOutlet private weak var catalogTableView: UITableView!
    @IBOutlet private weak var filterTableView: UITableView!
    
    //MARK: Button
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var hideFilterButton: UIButton!
    
    
    //MARK: Stack View
    @IBOutlet private weak var plusMinusStackView: UIStackView!
    
    //MARK: Indicator
    @IBOutlet private weak var categoryChangesActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraint
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var filterTableViewAppearceConstraint: NSLayoutConstraint!
    
}








//MARK: - Extention:

//MARK: - For Overrides
private extension CatalogListViewController {
    
    // - for view did load
    func forViewDidLoad() {
        categoryChangesActivityIndicator.stopAnimating()
        
        NetworkManager.shared.downloadProductInfo(success: { productInfo in
            self.productInfo = productInfo
            self.catalogTableView.reloadData()
        }) { error in
            print(error.localizedDescription)
        }
        
        employeePosition = CoreDataManager.shared.fetchEmployeePosition(failure: { (_) in
            self.transitionToExit(title: "Внимание", message: "Ошибка Аунтификации. Перезагрузите приложение")
        })
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
            plusMinusStackView.isHidden = false
        }
        
        NetworkManager.shared.downloadFilteringDict(success: { (data) in
            self.filterData = [filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: data.flower),
                               filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: data.bouquet),
                               filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: data.gift)]
            self.filterTableView.reloadData()
        }) { (error) in
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
            print("ERROR: CatalogViewController: viewWillAppear: downloadFilteringDict ", error.localizedDescription)
        }
        
    }
    
}

//MARK: - TableView Extention
extension CatalogListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == filterTableView {
            return filterData.count
        }else{
            return 1
        }
    }
    
    // - table view filling
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.catalogTableView {
            //            if searchActivity {
            //                return filteredProductsBySearchController?.count ?? 0
            //            }
            return productInfo.count
        }else{
            if filterData[section].opened == true {
                let count = filterData[section].sectionData.count + 1
                return count
            }else{
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.catalogTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.CatalogListTVCell.rawValue, for: indexPath) as! CatalogListTableViewCell
            
            cell.delegate = self
            cell.tag = indexPath.row
            
            let fetch = productInfo[cell.tag],
            name = fetch.productName,
            price = fetch.productPrice,
            category = fetch.productCategory,
            description = fetch.productDescription,
            stock = fetch.stock,
            position = employeePosition ?? ""
            
            if self.employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
                cell.stockSwitch.isHidden = false
                cell.productPriceButton.isUserInteractionEnabled = true
            }else{
                cell.stockSwitch.isHidden = true
                cell.productPriceButton.isUserInteractionEnabled = false
            }
            
            cell.fill(name: name, price: price, category: category, description: description, stock: stock, employeePosition: position, failure: { error in
                print("ERROR: CatalogListViewController/tableView/imageRef: ",error.localizedDescription)
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Не все изображения сейчас могут подтянуться"), animated: true)
            })
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.FilterTVCell.rawValue, for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = filterData[indexPath.section].title
                cell.textLabel?.textColor = UIColor.pinkColorOfEnterprise
                cell.backgroundColor = UIColor.purpleColorOfEnterprise
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                return cell
            }else{
                let dataIndex = indexPath.row - 1
                cell.textLabel?.text = filterData[indexPath.section].sectionData[dataIndex]
                cell.textLabel?.textColor = UIColor.purpleColorOfEnterprise
                cell.backgroundColor = UIColor.pinkColorOfEnterprise
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterTableView {
            if indexPath.row == 0  {
                filterData[indexPath.section].opened = !filterData[indexPath.section].opened
                let section = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(section, with: .none)
            }else{
                let dataIndex = indexPath.row - 1,
                title = filterData[indexPath.section].title,
                sectionData = filterData[indexPath.section].sectionData[dataIndex]
                
                if sectionData == "Все"{
                    NetworkManager.shared.downloadByCategory(category: title, success: { data in
                        self.filterTableViewAppearceConstraint.constant = self.hideUnhideFilter()
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.productInfo  = data
                            self.catalogTableView.reloadData()
                        }
                    }) { error in
                        self.present(UIAlertController.completionDoneTwoSec(title: "", message: ""), animated: true)
                        print("ERROR: CatalogViewController: tableView/didSelectRowAt: downloadByCategory", error.localizedDescription)
                    }
                }else{
                    
                    NetworkManager.shared.downloadBySubCategory(category: title, subCategory: sectionData, success: { (data) in
                        self.filterTableViewAppearceConstraint.constant = self.hideUnhideFilter()
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.productInfo = data
                            self.catalogTableView.reloadData()
                        }
                    }) { (error) in
                        self.present(UIAlertController.completionDoneTwoSec(title: "", message: ""), animated: true)
                        print("ERROR: CatalogViewController: didSelectRowAt: downloadBySubCategory: ", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // - delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.catalogTableView {
            if self.employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
                let delete = deleteAction(at: indexPath)
                return UISwipeActionsConfiguration(actions: [delete])
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            let fetch = self.productInfo[indexPath.row],
            name = fetch.productName,
            uid = CoreDataManager.shared.fetchEmployeeUID { (error) in
                self.present(UIAlertController.completionDoneTwoSec(title: "Эттеншн!", message: error.localizedDescription), animated: true)
            }
            
            if uid == AuthenticationManager.shared.uidAdmin {
                self.present(UIAlertController.confirmAction(message: "Подтвердите, что вы хотите удалить продукт под названием '\(name)'", confirm: {
                    NetworkManager.shared.deleteProduct(name: name)
                    self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Продукт удачно Удалён"), animated: true)
                    self.productInfo.remove(at: indexPath.row)
                    self.catalogTableView.deleteRows(at: [indexPath], with: .automatic)
                }), animated: true)
                complition(true)
            }else{
                self.present(UIAlertController.classic(title: "Эттеншн", message: "У Вас нет прав Самого Главного Администратора, чтобы удалять любую из позиций. Не ну ты ЧО"), animated: true)
                complition(false)
            }
        }
        action.backgroundColor = .red
        return action
    }
    
}

//MARK: - Cell delegate
extension CatalogListViewController: CatalogListTableViewCellDelegate {
    
    // -
    func editPrice(_ cell: CatalogListTableViewCell){
        guard let name = cell.productNameLabel.text else {return}
        
        if AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid {
            cell.productPriceButton.isUserInteractionEnabled = true
            
            self.present(UIAlertController.editProductPrice(name: name, confirm: { newPrice in
                cell.productPriceButton.setTitle("\(newPrice) грн", for: .normal)
            }),animated: true)
        }else{
            cell.productPriceButton.isUserInteractionEnabled = false
        }
        self.catalogTableView.reloadData()
    }
    
    // -
    func editStockCondition(_ cell: CatalogListTableViewCell, _ text: UILabel, _ switcher: UISwitch) {
        guard let name = cell.productNameLabel.text else {return}
        
        if cell.stockSwitch.isOn == true {
            self.present(UIAlertController.editStockCondition(name: name, stock: true, text: text, confirm: {
                self.productInfo.remove(at: cell.tag)
                self.catalogTableView.reloadData()
            }, cancel: {
                UIView.animate(withDuration: 0.3) {
                    switcher.setOn(true, animated: true)
                }
            }), animated: true)
        }else{
            self.present(UIAlertController.editStockCondition(name: name, stock: false, text: text, confirm: {
                self.productInfo.remove(at: cell.tag)
                self.catalogTableView.reloadData()
            }, cancel: {
                UIView.animate(withDuration: 0.3) {
                    switcher.setOn(false, animated: true)
                }
                
            }), animated: true)
        }
    }
    
}

//MARK: - Product filtration methods
//private extension CatalogListViewController {

// - hide unHide buttons
//    func showOptionsMethod(_ option: String) {
//        selectedCategory = option
//        allFilterButtonsCollection.forEach { (buttons) in
//            self.filterButton.isHidden = !self.buttonsView.isHidden
//            buttons.isHidden = !buttons.isHidden
//            UIView.animate(withDuration: 0.3) {
//                self.buttonsView.layoutIfNeeded()
//            }
//            filterButton.setTitle(option, for: .normal)
//        }
//    }

//    // - filtraiton
//    func selectionMethod(_ class: UIViewController, _ sender: UIButton) {
//        categoryChangesActivityIndicator.startAnimating()
//
//        guard let title = sender.currentTitle, let categories = NavigationCases.ProductCategoriesCases(rawValue: title) else {return}
//        switch categories {
//        case .flower:
//            showOptionsMethod(NavigationCases.ProductCategoriesCases.flower.rawValue)
//            NetworkManager.shared.downloadApieces(success: { productInfo in
//                self.productInfo = productInfo
//                self.filterButton.isHidden = false
//                self.tableView.reloadData()
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }) { error in
//                print(error.localizedDescription)
//                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Неожиданная потеря соединения"), animated: true)
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }
//        case .gift:
//            showOptionsMethod(NavigationCases.ProductCategoriesCases.gift.rawValue)
//            NetworkManager.shared.downloadGifts(success: { productInfo in
//                self.productInfo = productInfo
//                self.filterButton.isHidden = false
//                self.tableView.reloadData()
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }) { error in
//                print(error.localizedDescription)
//                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Неожиданная потеря соединения"), animated: true)
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }
//        case .bouquet:
//            showOptionsMethod(NavigationCases.ProductCategoriesCases.bouquet.rawValue)
//            NetworkManager.shared.downloadBouquets(success: { productInfo in
//                self.productInfo = productInfo
//                self.filterButton.isHidden = false
//                self.tableView.reloadData()
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }) { error in
//                print(error.localizedDescription)
//                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Неожиданная потеря соединения"), animated: true)
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }
//        case .stock:
//            showOptionsMethod(NavigationCases.ProductCategoriesCases.stock.rawValue)
//            NetworkManager.shared.downloadStocks(success: { productInfo in
//                self.productInfo = productInfo
//                self.filterButton.isHidden = false
//                self.tableView.reloadData()
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }) { error in
//                print(error.localizedDescription)
//                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Неожиданная потеря соединения"), animated: true)
//                self.categoryChangesActivityIndicator.stopAnimating()
//            }
//        }
//    }
//
//}

//MARK: - Plus or minus to product prices: depends on category.
private extension CatalogListViewController {
    
    func editPricesByCategory(_ sender: UIButton) {
        guard let title = sender.currentTitle,
            let cases = NavigationCases.MinusPlus(rawValue: title),
            let category = selectedCategory else {
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Вы не выбрали категорию, где необходимо изменить цены"), animated: true)
                return
        }
        switch cases {
        case .minus:
            self.present(UIAlertController.setNumber(present: "Введите сумму, которую вы хотите ОТНЯТЬ от всех товаров в данной категории", confirm: { (x) in
                NetworkManager.shared.increaseDecreasePrice(for: category, by: -x, success: {
                    self.present(UIAlertController.completionDoneHalfSec(title: "Готово!", message: "Стоимости изменены"), animated: true)
                }) { (error) in
                    self.present(UIAlertController.completionDoneTwoSec(title: "ERROR", message: error.localizedDescription), animated: true)
                }
            }), animated: true)
        case .plus:
            self.present(UIAlertController.setNumber(present: "Введите сумму, которую вы хотите ДОБАВИТЬ ко всем товарам в данной категории", confirm: { (x) in
                NetworkManager.shared.increaseDecreasePrice(for: category, by: x, success: {
                    self.present(UIAlertController.completionDoneHalfSec(title: "Готово!", message: "Стоимости изменены"), animated: true)
                }) { (error) in
                    self.present(UIAlertController.completionDoneTwoSec(title: "ERROR", message: error.localizedDescription), animated: true)
                }
            }), animated: true)
        }
    }
    
}


//MARK: - Hide Un Hide Any
private extension CatalogListViewController {
    
    func hideUnhideFilter() -> CGFloat {
        var constraint: CGFloat?
        if filterTableViewAppearceConstraint.constant == 0 {
            constraint = filterTableView.bounds.width
            hideFilterButton.alpha = 0.7
            filterTableView.alpha = 0.7
        }else{
            constraint = 0
            hideFilterButton.alpha = 0
            filterTableView.alpha = 0
        }
        return constraint ?? 0
    }
    
}
