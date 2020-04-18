//
//  CatalogListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 09.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseUI

//MARK: - Protocol Worker-Catalog-ViewControllerDelegate

protocol CatalogListTableViewCellDelegate: class {
    
    func editPrice(_ cell: CatalogListTableViewCell)
    
    func editStockCondition(_ cell: CatalogListTableViewCell, _ text: UILabel)
    
}


//MARK: - Core Class
class CatalogListTableViewCell: UITableViewCell {
    
    //MARK: - Implementation
    var price = Int()
    var category = String()
    var stock = false
    var employeePosition = String()
    weak var delegate: CatalogListTableViewCellDelegate?
    
    //MARK: - Label
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var stockConditionLabel: UILabel!
    
    //MARK: - ImageView
    @IBOutlet weak var productImageView: UIImageView!
    
    //MARK: - View
    @IBOutlet weak var descriptionView: UIView!
    
    //MARK: - Buttons
    @IBOutlet weak var productPriceButton: UIButton!
    
    //MARK: - Switch
    @IBOutlet weak var stockSwitch: UISwitch!
    
    //MARK: - Activity Indicator
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.5) {
            self.descriptionView.isHidden = !self.descriptionView.isHidden
        }
    }
    
    //MARK: - Price Editor
    @IBAction func priceTapped(_ sender: UIButton) {
        delegate?.editPrice(self)
    }
    
    @IBAction func stockCondition(_ sender: UISwitch) {
        delegate?.editStockCondition(self, stockConditionLabel)
    }
    
    
    //MARK: - Заполнение Таблицы
    func fill(name: String, price: Int, category: String, description: String, stock: Bool, employeePosition: String, failure: @escaping(Error) -> Void) {
        imageActivityIndicator.startAnimating()
        
        productNameLabel.text = name
        productPriceButton.setTitle("\(price) грн", for: .normal)
        productDescriptionLabel.text = description
        
        self.price = price
        self.category = category
        
        self.employeePosition = employeePosition
        if self.employeePosition == NavigationCases.EmployeeCases.admin.rawValue {
            self.stockSwitch.isHidden = false
            self.productPriceButton.isUserInteractionEnabled = true
        }else{
            self.stockSwitch.isHidden = true
            self.productPriceButton.isUserInteractionEnabled = false
        }
        
        self.stock = stock
        if self.stock == true {
            stockSwitch.isOn = true
            stockConditionLabel.text = "Акционный товар"
            stockConditionLabel.textColor = .red
        }else{
            stockSwitch.isOn = false
            stockConditionLabel.text = "Акция отсутствует"
            stockConditionLabel.textColor = .black
        }
        
        let storagePath = "\(NavigationCases.ProductCases.imageCollection.rawValue)/\(name)",
        storageRef = Storage.storage().reference(withPath: storagePath)
        productImageView.sd_setImage(with: storageRef, placeholderImage: .none) { (image, error, _, _) in
            if let error = error{
                self.imageActivityIndicator.stopAnimating()
                failure(error)
            }else{
                self.imageActivityIndicator.stopAnimating()
            }
        }
    }
    
}
