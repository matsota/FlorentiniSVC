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
        forViewDidLoad()
    }
    
    //MARK: - Prepare for Order Detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "orderList_OrderDetail", let OrderDetailVC = segue.destination as? OrderDetailListTableViewController, let index = tableView.indexPathsForSelectedRows?.first?.row {
            let detail = order[index]
            let currentDeviceID = detail.currentDeviceID
            OrderDetailVC.currentDeviceID = currentDeviceID
        }
    }
    
    //MARK: - Transition menu tapped
    @IBAction private func transitionMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
    }
    
    //MARK: - Transition confirm
    @IBAction func transitionConfim(_ sender: UIButton) {
        guard let title = sender.currentTitle,
               let view = transitionView,
               let constraint = transitionViewLeftConstraint,
               let button = transitionDismissButton else {return}
               
        transitionPerform(by: title, for: view, with: constraint, dismiss: button)
    }
    
    //MARK: - Transition dismiss
    @IBAction private func transitionDismiss(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
    }
    
    //MARK: - Private Implementation
    private var order = [DatabaseManager.Order]()
    private var orderCount = Int()
    
    //MARK: TableView
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: View
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Button
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    //MARK: Label
    @IBOutlet private weak var ordersCountLabel: UILabel!

    //MARK: Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
}









//MARK: - Extension:

//MARK: - For Overrides
private extension OrderListViewController {
    
    //MARK: for ViewDidLoad
    func forViewDidLoad() {
    
        NetworkManager.shared.fetchOrders(success: { (orders) in
            self.order = orders
            self.orderCount = orders.count
            self.ordersCountLabel.text = "Orders: \(self.orderCount)"
            self.tableView.reloadData()
        }) { error in
            self.present(UIAlertController.classic(title: "Attention", message: error.localizedDescription), animated: true)
        }
        
        NetworkManager.shared.updateOrders { newOrder in
            self.order.insert(newOrder, at: 0)
            self.orderCount += 1
            self.viewDidLoad()
        }
    }
    
}


//MARK: - by TableView
extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.OrdersListTVCell.rawValue, for: indexPath) as! OrderListTableViewCell,
        fetch = order[indexPath.row],
        bill = Int(fetch.totalPrice),
        orderKey = fetch.currentDeviceID,
        phoneNumber = fetch.cellphone,
        adress = fetch.adress,
        name = fetch.name,
        feedbackOption = fetch.feedbackOption,
        mark = fetch.mark,
        currentDeviceID = fetch.currentDeviceID,
        deliveryPerson = fetch.deliveryPerson
        
        cell.delegate = self
        
        cell.fill(bill: bill, orderKey: orderKey, phoneNumber: phoneNumber, adress: adress, name: name, feedbackOption: feedbackOption, mark: mark, deliveryPerson: deliveryPerson, currentDeviceID: currentDeviceID)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let archive = archiveAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [archive])
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
        id = fetch.currentDeviceID,
        deliveryPerson = fetch.deliveryPerson,
        
        action = UIContextualAction(style: .destructive, title: "Архив") { (action, view, complition) in
            self.present(UIAlertController.orderArchive(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, id: id, deliveryPerson: deliveryPerson, success: {
                self.orderCount -= 1
                self.order.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.viewDidLoad()
                self.present(UIAlertController.completionDoneTwoSec(title: "Эттеншн", message: "Заказ успершно архивирован"), animated: true)
                complition(true)
            }), animated: true)
        }
        return action
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
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
        id = fetch.currentDeviceID,
        deliveryPerson = fetch.deliveryPerson,
        
        action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            self.present(UIAlertController.orderDelete(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, id: id, deliveryPerson: deliveryPerson, success: {
                self.orderCount -= 1
                self.order.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.viewDidLoad()
                self.present(UIAlertController.completionDoneTwoSec(title: "Эттеншн", message: "Заказ успершно удален"), animated: true)
                complition(true)
            }), animated: true)
        }
        action.backgroundColor = .black
        return action
    }
    
}

//MARK: - Delivery Person
extension OrderListViewController: OrdersListTableViewCellDelegate {
    
    func deliveryPerson(_ cell: OrderListTableViewCell) {
        let currentDeviceID = cell.currentDeviceID
         
        self.present(UIAlertController.editDeliveryPerson(currentDeviceID: currentDeviceID, success: { (deliveryPerson) in
            cell.deliveryPersonButton.setTitle(deliveryPerson, for: .normal)
        }), animated:  true)
        self.tableView.reloadData()
    }
    
}
