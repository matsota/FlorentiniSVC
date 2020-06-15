//
//  OrderListViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 20.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit


class OrderListViewController: UIViewController {
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // - network
        NetworkManager.shared.downloadOrders(success: { (orders) in
            self.order = orders
            self.orderCount = orders.count
            self.navigationController?.navigationBar.topItem?.title = "Заказы: \(self.orderCount)"
            self.tableView.reloadData()
            
        }) { error in
            self.present(UIAlertController.classic(title: "Attention", message: error.localizedDescription), animated: true)
        }
        NetworkManager.shared.orderListener { newOrder in
            self.order.insert(newOrder, at: 0)
            self.orderCount += 1
            self.navigationController?.navigationBar.topItem?.title = "Заказы: \(self.orderCount)"
            self.tableView.reloadData()
        }
        
        // - coredata
        self.employeePosition = CoreDataManager.shared.fetchEmployeePosition()
        
    }
    
    //MARK: - Prepare for Order Detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NavigationCases.Transition.orderList_OrderDetail.rawValue, let orderDetailVC = segue.destination as? OrderDetailListTableViewController, let index = tableView.indexPathsForSelectedRows?.first {
            orderDetailVC.order = order[index.row]
            tableView.reloadData()
        }
    }
    
    //MARK: - Private Implementation
    private var order = [DatabaseManager.Order]()
    private var employeePosition: String?
    private var orderCount = Int()
    
    //MARK: TableView
    @IBOutlet private weak var tableView: UITableView!
    
}









//MARK: - Extension:

//MARK: - TableView
extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.OrdersListTVCell.rawValue, for: indexPath) as! OrderListTableViewCell,
        fetch = order[indexPath.row],
        bill = Int(fetch.totalPrice),
        orderKey = fetch.currentDeviceID,
        phoneNumber = fetch.cellphone,
        adress = fetch.adress,
        name = fetch.name,
        feedbackOption = fetch.feedbackOption,
        mark = fetch.mark,
        orderTime = Date.asString(fetch.timeStamp)(),
        orderID = fetch.orderID,
        deliveryPerson = fetch.deliveryPerson
        cell.delegate = self
        
        cell.fill(bill: bill, orderKey: orderKey, phoneNumber: phoneNumber, adress: adress, name: name, feedbackOption: feedbackOption, orderTime: orderTime, mark: mark, deliveryPerson: deliveryPerson, orderID: orderID)
        
        return cell
    }
    
    // - archive
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue || employeePosition == NavigationCases.EmployeeCases.operator.rawValue {
            let archive = archiveAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [archive])
        }else{
            return nil
        }
    }
    
    func archiveAction(at indexPath: IndexPath) -> UIContextualAction {
        let fetch = order[indexPath.row],
        totalPrice = fetch.totalPrice,
        name = fetch.name,
        adress = fetch.adress,
        cellphone = fetch.cellphone,
        feedbackOption = fetch.feedbackOption,
        mark = fetch.mark,
        timeStamp = fetch.timeStamp,
        currentDeviceID = fetch.currentDeviceID,
        deliveryPerson = fetch.deliveryPerson,
        orderID = fetch.orderID,
        
        action = UIContextualAction(style: .destructive, title: "Архив") { (action, view, complition) in
            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "", confirm: {
                let dataModel =  DatabaseManager.Order(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, currentDeviceID: currentDeviceID, deliveryPerson: deliveryPerson, orderID: orderID)
                NetworkManager.shared.archiveOrder(dataModel: dataModel, orderKey: orderID)
                self.orderCount -= 1
                self.order.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.viewDidLoad()
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Эттеншн", message: "Заказ успершно архивирован"), animated: true)
                complition(true)
            }), animated: true)
        }

        return action
    }
    
    // - delete
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            return nil
        }
        
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let fetch = order[indexPath.row],
        totalPrice = fetch.totalPrice,
        name = fetch.name,
        adress = fetch.adress,
        cellphone = fetch.cellphone,
        feedbackOption = fetch.feedbackOption,
        mark = fetch.mark,
        timeStamp = fetch.timeStamp,
        currentDeviceID = fetch.currentDeviceID,
        deliveryPerson = fetch.deliveryPerson,
        orderID = fetch.orderID,
        
        action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            self.present(UIAlertController.confirmAnyStyleActionSheet(message: "", confirm: {
                let dataModel =  DatabaseManager.Order(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, currentDeviceID: currentDeviceID, deliveryPerson: deliveryPerson, orderID: orderID)
                NetworkManager.shared.deleteOrder(dataModel: dataModel, orderID: dataModel.orderID)
                self.orderCount -= 1
                self.order.remove(at: indexPath.row)
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
    
    func deliveryPerson(_ cell: OrderListTableViewCell) {
        if employeePosition == NavigationCases.EmployeeCases.admin.rawValue || employeePosition == NavigationCases.EmployeeCases.operator.rawValue {
            
            self.present(UIAlertController.setNewString(message: "Введите Имя человека, который будет доставлять этот заказ", placeholder: "Введите Имя курьера", confirm: { (deliveryPerson) in
                guard let id = cell.orderID else {
                    self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ссылка не найдена"), animated: true)
                    return
                }
                NetworkManager.shared.updateDeliveryPerson(orderID: id, deliveryPerson: deliveryPerson)
                cell.deliveryPersonButton.setTitle(deliveryPerson, for: .normal)
            }), animated:  true)
            self.tableView.reloadData()
        }else{
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "У Вас недостаточно пользовательсих прав для назначения Курьера"), animated: true)
        }
    }
    
}

