//
//  OrderListViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 20.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit


class OrderListViewController: UIViewController{
    
    //MARK: - Override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        /// Network
        NetworkManager.shared.downloadOrders(success: { (orders) in
            self.newOrder = orders
            self.orderCount = orders.count
            self.navigationController?.navigationBar.topItem?.title = "Заказы: \(self.orderCount)"
            self.tableView.reloadData()
            
        }) { error in
            self.present(UIAlertController.classic(title: "Attention", message: error.localizedDescription), animated: true)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Network
        NetworkManager.shared.orderListener { newOrder in
            self.newOrder.insert(newOrder, at: 0)
            self.orderCount += 1
            self.navigationController?.navigationBar.topItem?.title = "Заказы: \(self.orderCount)"
            self.tableView.reloadData()
        }
        NetworkManager.shared.downloadEmployeesByTheirPosition(position: NavigationCases.EmployeeCases.delivery.rawValue, success: { (data) in
            let names = data.compactMap({$0.name})
            self.arrayOfDeliveryPersons = names
        }) { (error) in
            self.alertAboutConnectionLost(method: "downloadEmployeesByTheirPosition", error: error)
        }
        
        /// CoreData
        self.employeePosition = CoreDataManager.shared.fetchEmployeePosition()
        
        
        /// Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Prepare for Order Detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NavigationCases.Transition.orderList_OrderDetail.rawValue, let orderDetailVC = segue.destination as? OrderDetailListTableViewController, let index = tableView.indexPathsForSelectedRows?.first {
            orderDetailVC.order = newOrder[index.row]
            tableView.reloadData()
        }
    }
    
    //MARK: - Private Implementation
    private var newOrder = [DatabaseManager.Order](),
    orderCount = Int(),
    
    employeePosition: String?,
    
    currentTextField = UITextField(),
    arrayOfDeliveryPersons: [String]?,
    selectedDeliveryPerson: String?,
    indexRowOfCertainCell: Int?
    
    //MARK: TableView
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Constaint
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
}









//MARK: - Extension:

//MARK: - TableView
extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.OrdersListTVCell.rawValue, for: indexPath) as! OrderListTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        print(indexPath.row)
        print(cell.tag)
        
        let fetch = newOrder[cell.tag],
        bill = Int(fetch.totalPrice),
        phoneNumber = fetch.cellphone,
        adress = fetch.adress,
        name = fetch.name,
        feedbackOption = fetch.feedbackOption,
        mark = fetch.mark,
        orderTime = Date.asString(fetch.timeStamp)(),
        orderID = fetch.orderID,
        deliveryPerson = fetch.deliveryPerson
        
        
        cell.fill(bill: bill, phoneNumber: phoneNumber, adress: adress, name: name, feedbackOption: feedbackOption, orderTime: orderTime, mark: mark, deliveryPerson: deliveryPerson, orderID: orderID, indexRow: indexPath.row)
        
        return cell
    }
    
    // - archive
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue || employeePosition == NavigationCases.EmployeeCases.operator.rawValue {
//            let archive = archiveAction(at: indexPath)
//            return UISwipeActionsConfiguration(actions: [archive])
//        }else{
//            return nil
//        }
//    }
//
//    func archiveAction(at indexPath: IndexPath) -> UIContextualAction {
//        let fetch = newOrder[indexPath.row],
//        totalPrice = fetch.totalPrice,
//        name = fetch.name,
//        adress = fetch.adress,
//        cellphone = fetch.cellphone,
//        feedbackOption = fetch.feedbackOption,
//        mark = fetch.mark,
//        timeStamp = fetch.timeStamp,
//        currentDeviceID = fetch.currentDeviceID,
//        deliveryPerson = fetch.deliveryPerson,
//        orderID = fetch.orderID,
//
//        action = UIContextualAction(style: .destructive, title: "Архив") { (action, view, complition) in
//            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "", confirm: {
//                let dataModel =  DatabaseManager.Order(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, currentDeviceID: currentDeviceID, deliveryPerson: deliveryPerson, orderID: orderID)
//                NetworkManager.shared.archiveOrder(dataModel: dataModel, orderKey: orderID)
//                self.orderCount -= 1
//                self.newOrder.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                self.viewDidLoad()
//                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Эттеншн", message: "Заказ успершно архивирован"), animated: true)
//                complition(true)
//            }), animated: true)
//        }
//
//        return action
//    }
    
    // - delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            return nil
        }
        
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let fetch = newOrder[indexPath.row],
        
        action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "Подтвердите намерение Удалить этот заказ", confirm: {
                NetworkManager.shared.deleteOrder(dataModel: self.newOrder[indexPath.row], orderID: fetch.orderID) { _ in
                    
                }
                self.orderCount -= 1
                self.newOrder.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.viewDidLoad()
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Эттеншн", message: "Заказ успершно удален"), animated: true)
                complition(true)
            }), animated: true)
        }
        action.backgroundColor = .black
        return action
    }
    
}

//MARK: - Cell delegate
extension OrderListViewController: OrdersListTableViewCellDelegate {
    
    func textFieldDidBeginEditing(_ cell: OrderListTableViewCell, _ textField: UITextField, _ pickerView: UIPickerView) {
        hideKeyboardWhenTappedAround()
        currentTextField = textField
        if currentTextField == cell.deliveryPersonTextField{
            let doneButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(self.deliveryPersonConfirmed)),
            toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.setItems([doneButton], animated: true)
            
            currentTextField.inputAccessoryView = toolbar
            currentTextField.inputView = pickerView
        }
    }
    
    @objc func deliveryPersonConfirmed() {
        guard let person = selectedDeliveryPerson, let index = indexRowOfCertainCell else {
            return
        }
        let fetch = newOrder[index],
        
        id = fetch.orderID
        NetworkManager.shared.sentToProcessingOrders(dataModel: fetch, orderID: id, success: {
            NetworkManager.shared.updateDeliveryPerson(orderID: id, deliveryPerson: person)
            self.newOrder.remove(at: index)
            self.tableView.reloadData()
            }) { (error) in
                self.alertAboutConnectionLost(method: "deliveryPersonConfirmed: deleteOrder: sentToProcessingOrders", error: error)
            }
        
    }
    
    func returnRowsInPickerView(_ cell: OrderListTableViewCell) -> Int {
        if currentTextField == cell.deliveryPersonTextField{
            return arrayOfDeliveryPersons?.count ?? 1
        }else{
            return 0
        }
    }
    
    func returnNamesInPickerView(_ cell: OrderListTableViewCell, _ row: Int) -> String? {
        if currentTextField == cell.deliveryPersonTextField{
            return arrayOfDeliveryPersons?[row] ?? "В Базе нет Курьеров"
        }else{
            return ""
        }
    }
    
    func setDeliveryPerson(_ cell: OrderListTableViewCell, _ row: Int) {
        if currentTextField == cell.deliveryPersonTextField{
            self.selectedDeliveryPerson = arrayOfDeliveryPersons?[row]
            self.indexRowOfCertainCell = cell.indexRow
            cell.deliveryPersonTextField.text = arrayOfDeliveryPersons?[row]  ?? "В Базе нет Курьеров"
        }
    }
    
}


//MARK: Hide / Unhide Any
private extension OrderListViewController {
    
    /// When keyboard is going to show
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        tableViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.height - tabBarHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// When keyboard is going to hide
    @objc private func keyboardWillHide(notification: Notification) {
        tableViewBottomConstraint.constant = 14
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}



