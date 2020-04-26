//
//  EmployeesViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 17.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class EmployeeListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.fetchEmployeeData(success: { (data) in
            self.employeeData = data
            self.tableView.reloadData()
        }) { (error) in
            print("ERROR: EmployeeListViewController/viewDidLoad/fetchEmployeeData: ", error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "", message: ""), animated: true)
        }
        
        position = CoreDataManager.shared.fetchEmployeePosition { (error) in
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Ошибка Аутентификации"), animated: true)
        }
        
        if position != NavigationCases.EmployeeCases.admin.rawValue {
            employeeCreationButton.isHidden = true
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите имя сотрудника"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    //MARK: - Employee Creation
    // - hide unhide creation form
    @IBAction private func prepareForCreateNewEmployee(_ sender: DesignButton) {
        employeeCreationView.isHidden = !employeeCreationView.isHidden
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    // - hide unhide all position
    @IBAction private func showPositions(_ sender: DesignButton) {
        positionCollectionButton.forEach { (button) in
            positionButton.isHidden = !positionButton.isHidden
            button.isHidden = !button.isHidden
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    // - picked
    @IBAction private func positionPicked(_ sender: DesignButton) {
        guard let title = sender.currentTitle, let position = NavigationCases.EmployeeCases(rawValue: title) else {return}
        switch position {
            
        case .admin:
            positionForNewEmployee = NavigationCases.EmployeeCases.admin.rawValue
            positionButton.setTitle(positionForNewEmployee, for: .normal)
            positionCollectionButton.forEach { (button) in
                positionButton.isHidden = !positionButton.isHidden
                button.isHidden = !button.isHidden
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        case .operator:
            positionForNewEmployee = NavigationCases.EmployeeCases.operator.rawValue
            positionButton.setTitle(positionForNewEmployee, for: .normal)
            positionCollectionButton.forEach { (button) in
                positionButton.isHidden = !positionButton.isHidden
                button.isHidden = !button.isHidden
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        case .delivery:
            positionForNewEmployee = NavigationCases.EmployeeCases.delivery.rawValue
            positionButton.setTitle(positionForNewEmployee, for: .normal)
            positionCollectionButton.forEach { (button) in
                positionButton.isHidden = !positionButton.isHidden
                button.isHidden = !button.isHidden
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        default:
            positionForNewEmployee = "Не выбрана"
            positionButton.setTitle(positionForNewEmployee, for: .normal)
            positionCollectionButton.forEach { (button) in
                positionButton.isHidden = !positionButton.isHidden
                button.isHidden = !button.isHidden
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    // - create
    @IBAction private func createNewEmployee(_ sender: DesignButton) {
        guard let name = nameTextField.text,
            let email = emailTextField.text,
            let phone = phoneTextField.text else {
                self.present(UIAlertController.classic(title: "Внимание", message: "Заполинте все поля"), animated: true)
                return
        }
        
        let position = positionForNewEmployee
        if position == "Не выбрана" {
            self.present(UIAlertController.classic(title: "Внимание", message: "Вы забыли выбрать должность"), animated: true)
        }else if position == NavigationCases.EmployeeCases.admin.rawValue {
            self.present(UIAlertController.confrimAdminCreation {
                AuthenticationManager.shared.signUp(name: name, email: email, phone: phone, position: position, failure: { error in
                    self.present(UIAlertController.classic(title: "Эттеншн", message: error.localizedDescription), animated: true)
                })
            }, animated: true)
        }else{
            AuthenticationManager.shared.signUp(name: name, email: email, phone: phone, position: position, failure: { error in
                self.present(UIAlertController.classic(title: "Эттеншн", message: error.localizedDescription), animated: true)
            })
        }
        
    }
    
    //MARK: - Implementation
    private var employeeData = [DatabaseManager.EmployeeDataStruct]()
    private var filteredEmployessData = [DatabaseManager.EmployeeDataStruct]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: - Implementation
    private var position: String?
    private var positionForNewEmployee = "Не выбрана"
    
    //MARK: - Table view
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - View
    @IBOutlet private weak var employeeCreationView: UIView!
    
    
    //MARK: - Button
    
    @IBOutlet private weak var employeeCreationButton: DesignButton!
    @IBOutlet private weak var positionButton: DesignButton!
    @IBOutlet private var positionCollectionButton: [DesignButton]!
    
    //MARK: - Text Field
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var phoneTextField: UITextField!
    
    
    
}









//MARK: - Extension

//MARK: - Search Results
extension EmployeeListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(search: searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(search text: String) {
        filteredEmployessData = employeeData.filter({ (data: DatabaseManager.EmployeeDataStruct) -> Bool in
            return data.name.lowercased().contains(text.lowercased())
        })
        tableView.reloadData()
    }
    
}


//MARK: - Table View
extension EmployeeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredEmployessData.count
        }
        return employeeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.EmloyeeListTVCell.rawValue, for: indexPath) as! EmloyeeListTableViewCell
        
        cell.tag = indexPath.row
        cell.delegate = self
        
        var fetch: DatabaseManager.EmployeeDataStruct
        
        if isFiltering {
            fetch = self.filteredEmployessData[cell.tag]
        }else{
            fetch = self.employeeData[cell.tag]
        }
        
        let name = fetch.name,
        position = fetch.position,
        uid = fetch.uid
        
        cell.fill(name: name, position: position, uid: uid)
        print(name, position, uid)
        return cell
    }
    
    // - Delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let uid = CoreDataManager.shared.fetchEmployeeUID { (error) in
            print("ERROR: EmployeeListViewController/TableView/trailingSwipeActionsConfigurationForRowAt: ",error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Произошла ошибка"), animated: true)
        }
        if uid == AuthenticationManager.shared.uidAdmin {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            return nil
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            let fetch = self.employeeData[indexPath.row],
            name = fetch.name,
            uid = fetch.uid,
            phone = fetch.phone,
            position = fetch.position,
            success = fetch.success,
            failure = fetch.failure
            
            if uid == AuthenticationManager.shared.uidAdmin {
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Невозможно удалить данного Администратора"), animated: true)
                complition(false)
            }else{
                self.present(UIAlertController.confirmAction(message: "Подтвердите, что вы хотите удалить сотрудника под именем: '\(name)'", confirm: {
                    NetworkManager.shared.deleteEmployeeData(uid: uid, name: name, phone: phone, position: position, successed: success, fails: failure, {
                        self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Сотрудник удачно Удалён"), animated: true)
                        self.employeeData.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }) { (error) in
                        print("ERROR: EmployeeListViewController/Table View/deleteAction: ", error.localizedDescription)
                        self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Произошла Ошибка. Нет связи с сервером"), animated: true)
                    }
                    }), animated: true)
                complition(true)
            }
        }
        action.backgroundColor = .red
        return action
    }
    
}

//MARK: - Cell delegate
extension EmployeeListViewController: EmloyeeListTableViewCellDelegate {
    
    func changeEmployeePosition(_ cell: EmloyeeListTableViewCell) {
        
    }
    
}
