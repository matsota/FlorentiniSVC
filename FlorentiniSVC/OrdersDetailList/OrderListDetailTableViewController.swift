//
//  OrderDetailListTableViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 29.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseUI

class OrderDetailListTableViewController: UITableViewController {
    
    //MARK: - Implementation
    var order: DatabaseManager.Order?
    private var orderAddition = [DatabaseManager.OrderAddition]()
    
    
    //MARK: - Table View
    @IBOutlet private var orderDetailTableView: UITableView!
    
    
    //MARK: - Override
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if let orderID = order?.orderID {
            NetworkManager.shared.downloadOrderAdditions(orderRef: orderID, success: { (orders) in
                self.orderAddition = orders
                self.orderDetailTableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
        }
        
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderAddition.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.OrdersDetailListTVCell.rawValue, for: indexPath) as! OrderDetailListViewCell,
        fetch = orderAddition[indexPath.row],
        name  = fetch.productName,
        quantity = fetch.productQuantity,
        category = fetch.productCategory,
        price = Int(fetch.productPrice),
        stock = fetch.stock,
        productID = fetch.productID,
        storagePath = "\(NavigationCases.FirstCollectionRow.productImages.rawValue)/\(productID)",
        storageRef = Storage.storage().reference(withPath: storagePath)
        
        cell.imageActivityIndicator.isHidden = false
        cell.imageActivityIndicator.startAnimating()
        
        cell.fill(name: name, quantity: quantity, category: category, price: price, stock: stock, image: { (image) in
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
    
}









//MARK: - Extensions:

