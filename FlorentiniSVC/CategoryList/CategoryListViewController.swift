//
//  CatagoryListViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 11.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController {
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - network
        NetworkManager.shared.downloadSubCategoriesDict(success: { (data) in
            self.categoryData = [CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: data.flower),
                                 CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: data.bouquet),
                                 CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: data.gift)]
            self.tableView.reloadData()
        }) { (error) in
            self.alertAboutConnectionLost(method: "downloadSubCategoriesDict", error: error)
        }
        
        // - coredata
        userUID = CoreDataManager.shared.fetchEmployeeUID()
        employeePosition = CoreDataManager.shared.fetchEmployeePosition()
        
    }
    
    @IBAction func addSubCategoryTapped(_ sender: UIButton) {
        self.present(UIAlertController.addSubCategory(message: "", confirm: { (category) in
            let placeholder = "Введите подкатегою"
            if category == NavigationCases.ProductCategoriesCases.flower.rawValue{
                self.present(UIAlertController.setNewString(message: "Какую новую подкатегорию в желаете добавить к категории '\(category.uppercased())'", placeholder: placeholder, confirm: { (subCategory) in
                    NetworkManager.shared.downloadSubCategoriesDict(success: { (categoryArray) in
                        var array = categoryArray.flower
                        array.remove(at: 0)
                        array.append(subCategory)
                        array.sort(by: {$0.lowercased() < $1.lowercased()})
                        array.insert("Все", at: 0)
                        NetworkManager.shared.updateSubCategory(category: category, subCategory: array)
                        self.categoryData = [CatalogFilterListStruct(opened: true, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: array),
                                             CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: categoryArray.bouquet),
                                             CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: categoryArray.gift)]
                        self.tableView.reloadData()
                    }) { (error) in
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
                        print("ERROR: CatalogViewController: viewDidLoad: downloadFilteringDict ", error.localizedDescription)
                    }
                }), animated: true)
            }else if category == NavigationCases.ProductCategoriesCases.bouquet.rawValue{
                self.present(UIAlertController.setNewString(message: "Какую новую подкатегорию в желаете добавить к категории '\(category.uppercased())'", placeholder: placeholder, confirm: { (subCategory) in
                    NetworkManager.shared.downloadSubCategoriesDict(success: { (categoryArray) in
                        var array = categoryArray.bouquet
                        array.remove(at: 0)
                        array.append(subCategory)
                        array.sort(by: {$0.lowercased() < $1.lowercased()})
                        array.insert("Все", at: 0)
                        NetworkManager.shared.updateSubCategory(category: category, subCategory: array)
                        self.categoryData = [CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: categoryArray.flower),
                                             CatalogFilterListStruct(opened: true, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: array),
                                             CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: categoryArray.gift)]
                        self.tableView.reloadData()
                    }) { (error) in
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
                        print("ERROR: CatalogViewController: viewDidLoad: downloadFilteringDict ", error.localizedDescription)
                    }
                }), animated: true)
            }else if category == NavigationCases.ProductCategoriesCases.gift.rawValue{
                self.present(UIAlertController.setNewString(message: "Какую новую подкатегорию в желаете добавить к категории '\(category.uppercased())'", placeholder: placeholder, confirm: { (subCategory) in
                    NetworkManager.shared.downloadSubCategoriesDict(success: { (categoryArray) in
                        var array = categoryArray.gift
                        array.remove(at: 0)
                        array.append(subCategory)
                        array.sort(by: {$0.lowercased() < $1.lowercased()})
                        array.insert("Все", at: 0)
                        NetworkManager.shared.updateSubCategory(category: category, subCategory: array)
                        self.categoryData = [CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.flower.rawValue, sectionData: categoryArray.flower),
                                             CatalogFilterListStruct(opened: false, title: NavigationCases.ProductCategoriesCases.bouquet.rawValue, sectionData: categoryArray.bouquet),
                                             CatalogFilterListStruct(opened: true, title: NavigationCases.ProductCategoriesCases.gift.rawValue, sectionData: array)]
                        self.tableView.reloadData()
                    }) { (error) in
                        self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Скорее всего произошла потеря соединения"), animated: true)
                        print("ERROR: CatalogViewController: viewDidLoad: downloadFilteringDict ", error.localizedDescription)
                    }
                }), animated: true)
            }
        }),animated: true)
    }
    
    
    //MARK: - Implementation
    private var categoryData = [CatalogFilterListStruct]()
    
    private var employeePosition: String?,
    userUID: String?
    
    //MARK: Table View
    @IBOutlet private weak var tableView: UITableView!
    
}









//MARK: - Extension

//MARK: - Table View
extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    // - section
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return categoryData.count
        }else{
            return 1
        }
    }
    
    // - row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoryData[section].opened == true {
            let count = categoryData[section].sectionData.count + 1
            return count
        }
        return 1
    }
    
    // - cell for a row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.CategoryListTVCell.rawValue, for: indexPath)
        cell.textLabel?.textAlignment = .center
        if indexPath.row == 0 {
            cell.textLabel?.text = categoryData[indexPath.section].title
            cell.textLabel?.textColor = UIColor.pinkColorOfEnterprise
            cell.backgroundColor = UIColor.purpleColorOfEnterprise
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        }else{
            let dataIndex = indexPath.row - 1
            cell.textLabel?.text = categoryData[indexPath.section].sectionData[dataIndex]
            cell.textLabel?.textColor = UIColor.purpleColorOfEnterprise
            cell.backgroundColor = UIColor.pinkColorOfEnterprise
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            return cell
        }
    }
    
    // - did select 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            categoryData[indexPath.section].opened = !categoryData[indexPath.section].opened
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
        }
    }
    
    // - trailing swipe action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row > 0, self.employeePosition == NavigationCases.EmployeeCases.admin.rawValue, self.userUID == AuthenticationManager.shared.uidAdmin {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            return nil
        }
    }
    
    // - delete method
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            let dataIndex = indexPath.row - 1
            var subCategory = self.categoryData[indexPath.section].sectionData
            
            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "Подтвердите, что вы хотите удалить продукт под названием \(subCategory[dataIndex].uppercased())", confirm: {
                if subCategory[dataIndex] != "Все" {
                    // Вернуть "Амаралис"
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Подкатегория \(subCategory[dataIndex].uppercased()) удачно удалёна"), animated: true)
                    subCategory.remove(at: dataIndex)
                    self.categoryData[indexPath.section].sectionData = subCategory
                    self.tableView.reloadData()
                    let category = self.categoryData[indexPath.section].title
                    NetworkManager.shared.updateSubCategory(category: category,subCategory: subCategory)
                }else{
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Удалить подкатегорию 'Все' невозможно"), animated: true)
                    
                }
            }), animated: true)
            complition(true)
            
        }
        action.backgroundColor = .red
        return action
    }
    
}
