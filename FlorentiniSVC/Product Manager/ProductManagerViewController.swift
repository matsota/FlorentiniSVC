//
//  ProductManagerViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 13.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseUI

class ProductManagerViewController: UIViewController {
    
    //MARK: - Implementation
    var id: String?
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        /// ID
        productIDLabel.text = id
        
        /// Network data
        if let id = id {
            NetworkManager.shared.downloadCertainProduct(id: id, success: { (data) in
                /// set image
                let name = data.productName,
                storagePath = "\(NavigationCases.FirstCollectionRow.imageCollection.rawValue)/\(name)",
                storageRef = Storage.storage().reference(withPath: storagePath)
                self.productImageView.sd_setImage(with: storageRef, placeholderImage: .none)
                
                /// set price
                self.productPriceTextField.text = "\(data.productPrice)"
                /// set name
                self.productNameTextField.text = data.productName
                /// set category
                self.productCategoryTextField.text = data.productCategory
                /// set sub category
                self.productSubCategoryTextField.text = data.productSubCategory
                /// set description
                self.productDescriptionTextView.text = data.productDescription
                /// set search array
                var searchText = String()
                for i in data.searchArray {
                    searchText += "\(i) "
                }
                self.productSearchArrayTextView.text = searchText
                /// set stock condition
                if data.stock == true {
                    self.productStockConditionSwitch.isOn = true
                }
            }) { (error) in
                self.alertAboutConnectionLost(method: "downloadCertainProduct", error: error)
            }
        }
        /// Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        
        /// Set Text View
        cutomTextView(for: productDescriptionTextView, placeholder: "Введите описание продукта")
        cutomTextView(for: productSearchArrayTextView, placeholder: "Введите список отслеживаемых Слов для этого продукта")
        
        
    }
    
    
    //MARK: - UI Methods
    
    @IBAction func stockSwitchConditionTapped(_ sender: UISwitch) {
        
    }
    
    //MARK: - Private Implementation
    
    //MARK: Image
    @IBOutlet weak var productImageView: UIImageView!
    
    //MARK: Label
    @IBOutlet private weak var productIDLabel: UILabel!
    
    //MARK: TextField
    @IBOutlet weak var productPriceTextField: UITextField!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productCategoryTextField: UITextField!
    @IBOutlet weak var productSubCategoryTextField: UITextField!
    
    //MARK: TextView
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var productSearchArrayTextView: UITextView!
    
    //MARK: Switch
    @IBOutlet weak var productStockConditionSwitch: UISwitch!
    
    //MARK: Constraint
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var productDescriptionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productSearchArrayTextViewHeightConstraint: NSLayoutConstraint!
    
}









//MARK: - Extension
extension ProductManagerViewController {
    
}

//MARK: - Text View Delegate
extension ProductManagerViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите Описание Продукта" {
            textView.text = ""
            textView.textColor = UIColor.purpleColorOfEnterprise
        }else if textView.text == "Введите список отслеживаемых Слов для этого продукта"{
            textView.text = ""
            textView.textColor = UIColor.purpleColorOfEnterprise
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            if textView == productDescriptionTextView {
                textView.text = "Введите описание продукта"
                productDescriptionTextViewHeightConstraint.constant = 34
            }else{
                textView.text = "Введите список отслеживаемых Слов для этого продукта"
                productSearchArrayTextViewHeightConstraint.constant = 34
            }
            textView.textColor = .systemGray4
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == productDescriptionTextView{
            changeHeight(textView, for: productDescriptionTextViewHeightConstraint)
            //            let height = productSearchArrayTextViewHeightConstraint.constant
            //            textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            //            if height < 34 * 2.5 {
            //                let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            //                var newFrame = textView.frame
            //                newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
            //                productDescriptionTextViewHeightConstraint.constant = newFrame.height
            //                textView.frame = newFrame
            //            }
        }else{
            changeHeight(textView, for: productSearchArrayTextViewHeightConstraint)
            //            let height = productDescriptionTextViewHeightConstraint.constant
            //            textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            //            if height < 34 * 2.5 {
            //                let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            //                var newFrame = textView.frame
            //                newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
            //                productSearchArrayTextViewHeightConstraint .constant = newFrame.height
            //                textView.frame = newFrame
            //            }
        }
    }
    
    func changeHeight(_ textView: UITextView, for constaint: NSLayoutConstraint) {
        let width = textView.frame.size.width,
        height = constaint.constant
        textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        if height < 34 * 2.5 {
            let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
            constaint.constant = newFrame.height
            textView.frame = newFrame
        }
    }
    
}

//MARK: - Private Extention
private extension ProductManagerViewController {
    
    /// When keyboard is going to show
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
        let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.height - tabBarHeight
        print("YESSSS")
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// When keyboard is going to hide
    @objc private func keyboardWillHide(notification: Notification) {
        print("NOooooo")
        scrollViewBottomConstraint.constant = 14
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
