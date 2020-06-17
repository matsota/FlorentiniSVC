//
//  OrderListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 28.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

protocol OrdersListTableViewCellDelegate: class {
    
    func textFieldDidBeginEditing(_ cell: OrderListTableViewCell, _ textField: UITextField, _ pickerView: UIPickerView)
    
    func returnRowsInPickerView(_ cell: OrderListTableViewCell) -> Int
    
    func returnNamesInPickerView(_ cell: OrderListTableViewCell, _ row: Int) -> String?
    
    func setDeliveryPerson(_ cell: OrderListTableViewCell, _ row: Int)
}

class OrderListTableViewCell: UITableViewCell {
    
    //MARK: - Implementation
    var bill: Int?,
    orderID: String?,
    
    pickerView = UIPickerView(),
    deliveryPerson: String?,
    indexRow = Int()
    
    
    weak var delegate: OrdersListTableViewCellDelegate?
    
    //MARK: Label
    @IBOutlet private weak var billLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var adressLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var feedbackOptionLabel: UILabel!
    @IBOutlet private weak var orderTimeLabel: UILabel!
    @IBOutlet private weak var markLabel: UILabel!
    
    //MARK: TextField
    @IBOutlet weak var deliveryPersonTextField: UITextField!

    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.dataSource = self
        deliveryPersonTextField.delegate = self
    }
    
    //MARK: Override
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Заполнение таблицы
    func fill (bill: Int, phoneNumber: String, adress: String, name: String, feedbackOption: String, orderTime: String, mark: String, deliveryPerson: String, orderID: String, indexRow: Int) {
        
        self.bill = bill ; self.deliveryPerson = deliveryPerson ; self.orderID = orderID ; self.indexRow = indexRow
        
        billLabel.text = "\(bill) грн"
        phoneNumberLabel.text = phoneNumber
        adressLabel.text = adress
        nameLabel.text = name
        feedbackOptionLabel.text = feedbackOption
        orderTimeLabel.text = orderTime
        markLabel.text = mark
        
        
//        deliveryPersonButton.setTitle( self.deliveryPerson, for: .normal)
    }
    
}









//MARK: Extentions

//MARK: TextFiedl
extension OrderListTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self, textField, pickerView)
    }

}

//MARK: - PickerView
extension OrderListTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        delegate?.returnRowsInPickerView(self) ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        delegate?.returnNamesInPickerView(self, row) ?? ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        delegate?.setDeliveryPerson(self, row)
    }
    
}

