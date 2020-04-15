//
//  OrderListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 28.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

protocol OrdersListTableViewCellDelegate: class {
    func deliveryPerson (_ cell: OrderListTableViewCell)
}

class OrderListTableViewCell: UITableViewCell {
    
    //MARK: - Implementation
    var bill = Int()
    var orderKey = String()
    var deliveryPerson = String()
    var currentDeviceID = String()
    weak var delegate: OrdersListTableViewCellDelegate?
    
    //MARK: Label
    @IBOutlet private weak var billLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var adressLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var feedbackOptionLabel: UILabel!
    @IBOutlet private weak var markLabel: UILabel!
    
    //MARK: Button
    @IBOutlet weak var deliveryPersonButton: DesignButton!
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Override
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //        CoreDataManager.shared.saveOrderPath(orderPath: orderKey)
    }
    
    
    @IBAction func deliveryPersonTapped(_ sender: DesignButton) {
        delegate?.deliveryPerson(self)
    }
    
    //MARK: - Заполнение таблицы
    func fill (bill: Int, orderKey: String, phoneNumber: String, adress: String, name: String, feedbackOption: String, mark: String, deliveryPerson: String, currentDeviceID: String) {
        
        self.bill = bill
        self.orderKey = orderKey
        self.deliveryPerson = deliveryPerson
        self.currentDeviceID = currentDeviceID
        
        billLabel.text = "\(self.bill) грн"
        phoneNumberLabel.text = phoneNumber
        adressLabel.text = adress
        nameLabel.text = name
        feedbackOptionLabel.text = feedbackOption
        markLabel.text = mark
        
        deliveryPersonButton.setTitle( self.deliveryPerson, for: .normal)
    }
    
}
