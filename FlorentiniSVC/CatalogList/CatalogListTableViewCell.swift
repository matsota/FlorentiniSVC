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
    
    func editStockCondition(_ cell: CatalogListTableViewCell, _ text: UILabel, _ switcher: UISwitch)
    
    func transitionToProductManager(_ cell: CatalogListTableViewCell)
    
}


//MARK: - Core Class
class CatalogListTableViewCell: UITableViewCell {
    
    //MARK: - Implementation
    var id: String?
    var name: String?
    var price: Int?
    var category: String?
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
        let transitionPerform = UISwipeGestureRecognizer()
        transitionPerform.direction = .right
        transitionPerform.addTarget(self, action: #selector(self.transitionPerform(sender:)))
        self.contentView.addGestureRecognizer(transitionPerform)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionView.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.descriptionView.isHidden = !self.descriptionView.isHidden
        
    }
    
    //MARK: - Methods
    /// Transition to certain cell with data about certain product
    @objc private func transitionPerform(sender: UISwipeGestureRecognizer) {
        delegate?.transitionToProductManager(self)
    }
    
    /// Price edit Method
    @IBAction func priceTapped(_ sender: UIButton) {
        delegate?.editPrice(self)
    }
    
    /// Edit stock condition Method
    @IBAction func stockCondition(_ sender: UISwitch) {
        delegate?.editStockCondition(self, stockConditionLabel, stockSwitch)
    }
    
    /// Fill
    func fill(id: String, name: String, price: Int, category: String, description: String, stock: Bool, employeePosition: String, failure: @escaping(Error) -> Void) {
        
        self.price = price ; self.category = category ;  self.name = name ; self.id = id
        
        imageActivityIndicator.startAnimating()
        
        productNameLabel.text = name
        productPriceButton.setTitle("\(price) грн", for: .normal)
        productDescriptionLabel.text = description
        
        if stock == true {
            stockSwitch.isOn = true
            stockConditionLabel.text = "Акционный товар"
            stockConditionLabel.textColor = .red
        }else{
            stockSwitch.isOn = false
            stockConditionLabel.text = "Акция отсутствует"
            stockConditionLabel.textColor = .black
        }
        
        let storagePath = "\(NavigationCases.FirstCollectionRow.imageCollection.rawValue)/\(name)",
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
