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
        // - activity indicator
        categoryChangesActivityIndicator.stopAnimating()
        
        // - Network data
        NetworkManager.shared.downloadProducts(success: { productInfo in
            self.productInfo = productInfo
            self.catalogTableView.reloadData()
        }) { error in
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
            print("ERROR: CatalogViewController: viewDidLoad: downloadProductInfo ", error.localizedDescription)
        }
        NetworkManager.shared.downloadDictForFilteringTableView(success: { (data) in
            self.filterData = [filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: data.flower),
                               filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: data.bouquet),
                               filterTVStruct(opened: false, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: data.gift)]
            self.filterTableView.reloadData()
        }) { (error) in
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
            print("ERROR: CatalogViewController: viewDidLoad: downloadFilteringDict ", error.localizedDescription)
        }
        
        // - Core data
        employeePosition = CoreDataManager.shared.fetchEmployeePosition(failure: { (_) in
            self.transitionToExit(title: "Внимание", message: "Ошибка Аунтификации. Перезагрузите приложение")
        })
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
            plusMinusStackView.isHidden = false
        }
        
        // - keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        
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
    private var productInfo: [DatabaseManager.ProductInfo]?
    private var filteredProductInfoBySearchBar: [DatabaseManager.ProductInfo]?
    private var searchActivity = false
    private var filterData = [filterTVStruct]()
    private var employeePosition: String?
    private var selectedCategory: String?
    private var selectedSubCategory: String?
    
    
    //MARK: Searchbar
    @IBOutlet private weak var searchBar: UISearchBar!
    
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

//MARK: - Search Result
extension CatalogListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredProductInfoBySearchBar = productInfo?.filter({ (data) -> Bool in
                searchActivity = true
                return data.searchArray.contains { (string) -> Bool in
                    string.prefix(searchText.count).lowercased() == searchText.lowercased()
                }
            })
            self.catalogTableView.reloadData()
        }else{
            searchBar.placeholder = "Начните поиск"
            self.searchActivity = false
            self.catalogTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.placeholder = "Начните поиск"
        catalogTableView.reloadData()
    }
    
}

//MARK: - TableView
extension CatalogListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // - Number Of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == filterTableView {
            return filterData.count
        }else{
            return 1
        }
    }
    
    // - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == catalogTableView {
            if searchActivity {
                return filteredProductInfoBySearchBar?.count ?? 0
            }
            return productInfo?.count ?? 0
        }else{
            if filterData[section].opened == true {
                let count = filterData[section].sectionData.count + 1
                return count
            }else{
                return 1
            }
        }
    }
    
    // - Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == catalogTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.CatalogListTVCell.rawValue, for: indexPath) as! CatalogListTableViewCell
            
            cell.delegate = self
            cell.tag = indexPath.row
            
            var fetch: DatabaseManager.ProductInfo?
            
            if searchActivity {
                fetch = self.filteredProductInfoBySearchBar?[cell.tag]
            }else{
                fetch = self.productInfo?[cell.tag]
            }
            
            guard let name = fetch?.productName,
                let price = fetch?.productPrice,
                let category = fetch?.productCategory,
                let description = fetch?.productDescription,
                let stock = fetch?.stock else {return cell}
            let position = employeePosition ?? ""
            
            if self.employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
                cell.stockSwitch.isHidden = false
                cell.productPriceButton.isUserInteractionEnabled = true
            }else{
                cell.stockSwitch.isHidden = true
                cell.productPriceButton.isUserInteractionEnabled = false
            }
            
            cell.fill(name: name, price: price, category: category, description: description, stock: stock, employeePosition: position, failure: { error in
                print("ERROR: CatalogListViewController/tableView/imageRef: ",error.localizedDescription)
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Не все изображения сейчас могут подтянуться"), animated: true)
            })
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.FilterTVCell.rawValue, for: indexPath)
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
    
    // - Did Select Row
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
                    NetworkManager.shared.downloadProductsByCategory(category: title, success: { data in
                        self.selectedCategory = title
                        self.selectedSubCategory = nil
                        
                        self.filterTableViewAppearceConstraint.constant = self.hideUnhideFilter()
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.productInfo  = data
                            self.catalogTableView.reloadData()
                        }
                    }) { error in
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "", message: ""), animated: true)
                        print("ERROR: CatalogViewController: tableView/didSelectRowAt: downloadByCategory", error.localizedDescription)
                    }
                }else{
                    NetworkManager.shared.downloadProductsBySubCategory(subCategory: sectionData, success: { (data) in
                        self.selectedCategory = nil
                        self.selectedSubCategory = sectionData
                        self.filterTableViewAppearceConstraint.constant = self.hideUnhideFilter()
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.productInfo = data
                            self.catalogTableView.reloadData()
                        }
                    }) { (error) in
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "", message: ""), animated: true)
                        print("ERROR: CatalogViewController: didSelectRowAt: downloadBySubCategory: ", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // - UISwipeActions trailing
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
    
    // - delete method
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            guard let fetch = self.productInfo?[indexPath.row] else {return}
            let name = fetch.productName,
            uid = CoreDataManager.shared.fetchEmployeeUID { (error) in
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Эттеншн!", message: error.localizedDescription), animated: true)
            }
            
            if uid == AuthenticationManager.shared.uidAdmin {
                self.present(UIAlertController.confirmAnyStyleActionSheet(message: "Подтвердите, что вы хотите удалить продукт под названием '\(name)'", confirm: {
                    NetworkManager.shared.deleteProduct(name: name)
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Продукт удачно Удалён"), animated: true)
                    self.productInfo?.remove(at: indexPath.row)
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
    
    // - Price
    func editPrice(_ cell: CatalogListTableViewCell){
        guard let name = cell.productNameLabel.text else {return}
        if AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid {
            cell.productPriceButton.isUserInteractionEnabled = true
            
            self.present(UIAlertController.setNewInteger(message: "Введите новую цену для этого продукта"){ newNumber in
                NetworkManager.shared.editPriceOfCertainProduct(name: name, newPrice: newNumber)
                cell.productPriceButton.setTitle("\(newNumber) грн", for: .normal)
            },animated: true)
        }else{
            cell.productPriceButton.isUserInteractionEnabled = false
        }
        self.catalogTableView.reloadData()
    }
    
    // - Stock
    func editStockCondition(_ cell: CatalogListTableViewCell, _ text: UILabel, _ switcher: UISwitch) {
        guard let name = cell.productNameLabel.text else {return}
        
        if cell.stockSwitch.isOn == true {
            self.present(UIAlertController.confirmAnyStyleAlert(message: "Подтвердите изменение наличия АКЦИИ", confirm: {
                NetworkManager.shared.editStockCondition(name: name, stock: true)
                text.text = "Акционный товар"
                text.textColor = .red
                self.productInfo?.remove(at: cell.tag)
                self.catalogTableView.reloadData()
            }, cancel: {
                switcher.setOn(true, animated: true)
            }), animated: true)
        }else{
            self.present(UIAlertController.confirmAnyStyleAlert(message: "Подтвердите изменение наличия АКЦИИ", confirm: {
                NetworkManager.shared.editStockCondition(name: name, stock: false)
                text.text = "Акция отсутствует"
                text.textColor = .black
                
                self.productInfo?.remove(at: cell.tag)
                self.catalogTableView.reloadData()
            }, cancel: {
                switcher.setOn(false, animated: true)
            }), animated: true)
        }
    }
    
}

//MARK: - Plus or minus to product prices: depends on category.
private extension CatalogListViewController {
    
    // - All prices by category
    func editPricesByCategory(_ sender: UIButton) {
        guard let title = sender.currentTitle,
            let cases = NavigationCases.MinusPlus(rawValue: title),
            let category = selectedCategory else {
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Вы не выбрали категорию, где необходимо изменить цены"), animated: true)
                return
        }
        switch cases {
        case .minus:
            self.present(UIAlertController.setNewInteger(message: "Введите сумму, которую вы хотите ОТНЯТЬ от всех товаров в данной категории", confirm: { (x) in
                NetworkManager.shared.increaseDecreaseAllPricesByCategory(for: category, by: -x, success: {
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Готово!", message: "Стоимости изменены"), animated: true)
                }) { (error) in
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "ERROR", message: error.localizedDescription), animated: true)
                }
            }), animated: true)
        case .plus:
            self.present(UIAlertController.setNewInteger(message: "Введите сумму, которую вы хотите ДОБАВИТЬ ко всем товарам в данной категории", confirm: { (x) in
                NetworkManager.shared.increaseDecreaseAllPricesByCategory(for: category, by: x, success: {
                    self.present(UIAlertController.alertAppearanceForHalfSec(title: "Готово!", message: "Стоимости изменены"), animated: true)
                }) { (error) in
                    self.present(UIAlertController.alertAppearanceForHalfSec(title: "ERROR", message: error.localizedDescription), animated: true)
                }
            }), animated: true)
        }
    }
    
    // - All prices by Subcategory
    
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
    
    @objc func keyboardWillShow(notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
    }
    
}
