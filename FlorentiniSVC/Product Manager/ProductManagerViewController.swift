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
        /// Activity Indicator
        activityIndicator.stopAnimating()
        /// ID
        productIDLabel.text = id
        /// Network data
        if let id = id {
            NetworkManager.shared.downloadCertainProduct(id: id, success: { (data) in
                self.productData = data
                /// set image
                let storagePath = "\(NavigationCases.FirstCollectionRow.productImages.rawValue)/\(id)",
                storageRef = Storage.storage().reference(withPath: storagePath)
                self.productImageView.sd_setImage(with: storageRef, placeholderImage: .none)
                /// set price
                self.productPriceTextField.text = "\(data.productPrice)"
                /// set name
                self.productNameTextField.text = data.productName
                /// set category
                self.selectedCategory = data.productCategory
                self.productCategoryTextField.text = self.selectedCategory
                /// set sub category
                self.selectedSubCategory = data.productSubCategory
                self.productSubCategoryTextField.text = self.selectedSubCategory
                /// set description
                self.productDescriptionTextView.delegate = self
                self.productDescription = data.productDescription
                self.productDescriptionTextView.text =  self.productDescription
                self.cutomsTextView(for: self.productDescriptionTextView, placeholder: "Введите описание продукта")
                self.changeTextViewHeightDependsOnTextLength(self.productDescriptionTextView, for: self.productDescriptionTextViewHeightConstraint)
                /// set search array
                self.productSearchArrayTextView.delegate = self
                for i in data.searchArray {
                    self.searchArrayAsString += "\(i), "
                }
                self.productSearchArrayTextView.text = self.searchArrayAsString
                self.cutomsTextView(for: self.productSearchArrayTextView, placeholder: "Введите список отслеживаемых Слов для этого продукта")
                self.changeTextViewHeightDependsOnTextLength(self.productSearchArrayTextView, for: self.productSearchArrayTextViewHeightConstraint)
                /// set stock condition
                if data.stock == true {
                    self.productStockConditionSwitch.isOn = true
                }
            }) { (error) in
                self.alertAboutConnectionLost(method: "downloadCertainProduct", error: error)
            }
        }
        NetworkManager.shared.downloadCategoriesDict(success: { (categories) in
            self.categories = categories.allCategories
        }) { (error) in
            self.alertAboutConnectionLost(method: "downloadCategoriesDict", error: error)
        }
        NetworkManager.shared.downloadSubCategoriesDict(success: { (subCategory) in
            self.flowerCategories = subCategory.flower
            self.bouquetCategories = subCategory.bouquet
            self.giftCategories = subCategory.gift
        }) { (error) in
            self.alertAboutConnectionLost(method: "downloadSubCategoriesDict", error: error)
        }
        
        /// Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        //        navigationController?.hidesBarsWhenKeyboardAppears = true
        
        /// Set Edit && Save && Cancel buttons for product
        setUpEditingButtons()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        productNameTextField.isEnabled = editing ? true : false
        productPriceTextField.isEnabled = editing ? true : false
        productCategoryTextField.isEnabled = editing ? true : false
        productSubCategoryTextField.isEnabled = editing ? true : false
        productDescriptionTextView.isEditable = editing ? true : false
        productSearchArrayTextView.isEditable = editing ? true : false
        productStockConditionSwitch.isEnabled = editing ? true : false
        self.navigationItem.leftBarButtonItem = editing ? cancelButton : backButton
        self.navigationItem.rightBarButtonItem = editing ? saveButton : editButtonItem
    }
    
    
    //MARK: - UI Methods
    
    @IBAction func stockSwitchConditionTapped(_ sender: UISwitch) {
        
    }
    
    //MARK: - Private Implementation
    private var backButton: UIBarButtonItem!,
    saveButton: UIBarButtonItem!,
    cancelButton: UIBarButtonItem!,
    
    pickerView = UIPickerView(),
    currentTextField = UITextField(),
    
    categories = [String](),
    flowerCategories = [String](),
    bouquetCategories = [String](),
    giftCategories = [String](),
    selectedSubCategories = [String](),
    
    selectedCategory = String(),
    selectedSubCategory = String(),
    
    productDescription = String(),
    searchArrayAsString = String(),
    
    productData: DatabaseManager.ProductInfo?
    
    //MARK: Image
    @IBOutlet private weak var productImageView: UIImageView!
    
    //MARK: Label
    @IBOutlet private weak var productIDLabel: UILabel!
    
    //MARK: TextField
    @IBOutlet private weak var productPriceTextField: UITextField!
    @IBOutlet private weak var productNameTextField: UITextField!
    @IBOutlet private weak var productCategoryTextField: UITextField!
    @IBOutlet private weak var productSubCategoryTextField: UITextField!
    
    //MARK: TextView
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    @IBOutlet private weak var productSearchArrayTextView: UITextView!
    
    //MARK: Switch
    @IBOutlet private weak var productStockConditionSwitch: UISwitch!
    
    //MARK: Activiry indicator
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraint
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var productDescriptionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var productSearchArrayTextViewHeightConstraint: NSLayoutConstraint!
    
}









//MARK: - Extension

//MARK: - PickerView
extension ProductManagerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == productCategoryTextField {
            return categories.count
        }else if currentTextField == productSubCategoryTextField {
            if selectedCategory == NavigationCases.ProductCategoriesCases.flower.rawValue {
                selectedSubCategories = flowerCategories
            }else if selectedCategory == NavigationCases.ProductCategoriesCases.bouquet.rawValue {
                selectedSubCategories = bouquetCategories
            }else if selectedCategory == NavigationCases.ProductCategoriesCases.gift.rawValue {
                selectedSubCategories = giftCategories
            }
            return selectedSubCategories.count
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == productCategoryTextField {
            return categories[row]
        }else if currentTextField == productSubCategoryTextField {
            if selectedCategory == NavigationCases.ProductCategoriesCases.flower.rawValue {
                selectedSubCategories = flowerCategories
            }else  if selectedCategory == NavigationCases.ProductCategoriesCases.bouquet.rawValue {
                selectedSubCategories = bouquetCategories
            }else  if selectedCategory == NavigationCases.ProductCategoriesCases.gift.rawValue {
                selectedSubCategories = giftCategories
            }
            return selectedSubCategories[row]
        }else{
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == productCategoryTextField {
            selectedCategory = categories[row]
            productCategoryTextField.text = selectedCategory
            productSubCategoryTextField.text = nil
            selectedSubCategory = ""
            pickerView.reloadAllComponents()
        }else if currentTextField == productSubCategoryTextField {
            selectedSubCategory = selectedSubCategories[row]
            productSubCategoryTextField.text = selectedSubCategory
        }
    }
    
}

//MARK: - TexField
extension ProductManagerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.dataSource = self
        pickerView.delegate = self
        currentTextField = textField
        if currentTextField == productCategoryTextField {
            currentTextField.inputView = pickerView
        }else if textField == productSubCategoryTextField {
            if selectedCategory == "" {
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Вы не выбрали категорию"), animated: true)
            }else{
                currentTextField.inputView = pickerView
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "Все" {
            textField.text = nil
        }
    }
    
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
            changeTextViewHeightDependsOnTextLength(textView, for: productDescriptionTextViewHeightConstraint)
        }else{
            changeTextViewHeightDependsOnTextLength(textView, for: productSearchArrayTextViewHeightConstraint)
        }
    }
    
}

//MARK: - Private Extention
private extension ProductManagerViewController {
    
    ///
    func setUpEditingButtons() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.backButton = navigationItem.leftBarButtonItem
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }
    
    @objc private func save() {
        activityIndicator.startAnimating()
        self.setEditing(false, animated: true)
        guard let id = id,
            let name = productNameTextField.text,
            let price = Int(productPriceTextField.text!),
            let category = productCategoryTextField.text,
            let subCategory = productSubCategoryTextField.text,
            let description = productDescriptionTextView.text else {return}
        let stock = productStockConditionSwitch.isOn,
        defaultString = "Введите список отслеживаемых Слов для этого продукта"
        
        var searchArray = productSearchArrayTextView.text.convertStringIntoArray()
        if searchArray == [], searchArray == defaultString.convertStringIntoArray() {
            searchArray = [name, category, subCategory]
        }
        
        NetworkManager.shared.updateAllProductProperties(docID: id, name: name, price: price, category: category,
        subCategory: subCategory, description: description, searchArray: searchArray, stock: stock, success: {
            self.present(UIAlertController.alertAppearanceForHalfSec(title: "Успех", message: "Продукт изменён"), animated: true)
            self.activityIndicator.stopAnimating()
        }) { (error) in
            self.alertAboutConnectionLost(method: "updateAllProductProperties", error: error)
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc private func cancel() {
        self.setEditing(false, animated: true)
        productNameTextField.text = productData?.productName
        productPriceTextField.text = "\(productData?.productPrice ?? 0)"
        
        productCategoryTextField.text = productData?.productCategory
        productSubCategoryTextField.text = productData?.productSubCategory
        
        productDescriptionTextView.text = productDescription
        cutomsTextView(for: self.productDescriptionTextView, placeholder: "Введите описание продукта")
        changeTextViewHeightDependsOnTextLength(self.productDescriptionTextView, for: self.productDescriptionTextViewHeightConstraint)
        
        productSearchArrayTextView.text = searchArrayAsString
        cutomsTextView(for: self.productSearchArrayTextView, placeholder: "Введите список отслеживаемых Слов для этого продукта")
        changeTextViewHeightDependsOnTextLength(self.productSearchArrayTextView, for: self.productSearchArrayTextViewHeightConstraint)
        
        if productData?.stock == true {
            productStockConditionSwitch.isOn = true
        }else{
            productStockConditionSwitch.isOn = false
        }
    }
    
    /// When keyboard is going to show
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.height - tabBarHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// When keyboard is going to hide
    @objc private func keyboardWillHide(notification: Notification) {
        //        navigationController?.isNavigationBarHidden = false
        scrollViewBottomConstraint.constant = 14
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
