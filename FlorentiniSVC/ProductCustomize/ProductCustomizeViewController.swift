//
//  ProductCustomizeViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 27.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProductCustomizeViewController: UIViewController {
    
    //MARK: - ViewDidLoad Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // - activity indicator
        imageActivityIndicator.isHidden = true
        
        // - network
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
        
        // - keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        // - text view
        cutomTextView(for: descriptionTextView, placeholder: "Введите Описание Продукта")
        descriptionTextView.delegate = self
        
    }
    
    //MARK: - Download image by URL
    @IBAction func downLoadByURLTapped(_ sender: UIButton) {
        downloadByURL()
    }
    
    //MARK: - Download from gallery
    @IBAction func galleryTapped(_ sender: UIButton) {
        downLoadPhotoFromLibrary()
    }
    
    //MARK: - Download by picture shot
    @IBAction func cameraTapped(_ sender: UIButton) {
        makePhoto()
    }
    
    //MARK: - Upload to Firebase
    @IBAction func uploadTapped(_ sender: UIButton) {
        productCreationConfirms()
    }
    
    //MARK: - Stock condition
    @IBAction func stockCondition(_ sender: UISwitch) {
        if stockSwitch.isOn == true {
            stock = true
            stockConditionLabel.text = "Акционный товар"
        }else{
            stock = false
            stockConditionLabel.text = "Без акции"
        }
        
    }
    
    //MARK: - Private Implementation
    private var pickerView = UIPickerView(),
    currentTextField = UITextField(),
    categories = [String](),
    flowerCategories = [String](),
    bouquetCategories = [String](),
    giftCategories = [String](),
    selectedSubCategories = [String](),
    selectedCategory = String(),
    selectedSubCategory = String(),
    givenUrl: URL?,
    stock = false
    
    //MARK: ImageView
    @IBOutlet private weak var addedPhotoImageView: UIImageView!
    
    //MARK: ScrollView
    @IBOutlet private weak var scrollView: UIScrollView!
    
    //MARK: TextField
    @IBOutlet private weak var photoNameTextField: UITextField!
    @IBOutlet private weak var photoPriceTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var subCategoryTextField: UITextField!
    
    //MARK: TextView
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    //MARK: Label
    @IBOutlet private weak var stockConditionLabel: UILabel!
    
    //MARK: Switch
    @IBOutlet private weak var stockSwitch: UISwitch!
    
    //MARK: ProgressView
    @IBOutlet private weak var progressView: UIProgressView!
    
    //MARK: Activity Indicator
    @IBOutlet private weak var imageActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraints
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
}









//MARK: - Extension:

//MARK: - PickerView
extension ProductCustomizeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == categoryTextField {
            return categories.count
        }else if currentTextField == subCategoryTextField {
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
        if currentTextField == categoryTextField {
            return categories[row]
        }else if currentTextField == subCategoryTextField {
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
        if currentTextField == categoryTextField {
            selectedCategory = categories[row]
            categoryTextField.text = selectedCategory
            subCategoryTextField.text = nil
            selectedSubCategory = ""
            pickerView.reloadAllComponents()
        }else if currentTextField == subCategoryTextField {
            selectedSubCategory = selectedSubCategories[row]
            subCategoryTextField.text = selectedSubCategory
        }
    }
    
}

//MARK: - TexField
extension ProductCustomizeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.dataSource = self
        pickerView.delegate = self
        currentTextField = textField
        if currentTextField == categoryTextField {
            currentTextField.inputView = pickerView
        }else if textField == subCategoryTextField {
            if selectedCategory == ""{
                self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Вы не выбрали категорию"), animated: true)
            }else{
                currentTextField.inputView = pickerView
            }
        }
    }
    
}

//MARK: - Text View Delegate
extension ProductCustomizeViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите Описание Продукта" {
            textView.text = ""
            textView.textColor = UIColor.purpleColorOfEnterprise
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Введите Описание Продукта"
            textView.textColor = .systemGray4
            textViewHeightConstraint.constant = 34
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let width = textView.frame.size.width,
        height = textViewHeightConstraint.constant
        textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        if height < 34 * 2.5 {
            let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
            textViewHeightConstraint.constant = newFrame.height
            textView.frame = newFrame
        }
    }
    
}

//MARK: -

//MARK: - Image picker dalegate

extension ProductCustomizeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageActivityIndicator.isHidden = false
        imageActivityIndicator.startAnimating()
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.addedPhotoImageView.image = image
            self.imageActivityIndicator.isHidden = true
            self.imageActivityIndicator.stopAnimating()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - For product creation
private extension ProductCustomizeViewController {
    
    func makePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            self.imageActivityIndicator.isHidden = false
            self.imageActivityIndicator.startAnimating()
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.allowsEditing = false
            
            self.present(image, animated: true){
                self.imageActivityIndicator.isHidden = true
                self.imageActivityIndicator.stopAnimating()
            }
        }else{
            self.present(UIAlertController.classic(title: "Внимание", message: "Камера не доступна"), animated: true)
        }
    }
    
    func downLoadPhotoFromLibrary() {
        self.imageActivityIndicator.isHidden = false
        self.imageActivityIndicator.startAnimating()
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true){
            self.imageActivityIndicator.isHidden = true
            self.imageActivityIndicator.stopAnimating()
        }
    }
    
    func downloadByURL() {
        self.present(UIAlertController.setNewString(message: "Введите ссылку от куда возможно загрузить изображение", placeholder: "Введите ссылку", confirm: { url in
            self.imageActivityIndicator.isHidden = false
            self.imageActivityIndicator.startAnimating()
            NetworkManager.shared.downloadImageByURL(url: url) { image in
                self.addedPhotoImageView.image = image
                self.imageActivityIndicator.isHidden = true
                self.imageActivityIndicator.stopAnimating()
            }
        }), animated: true)
    }
    
    func productCreationConfirms() {
        let price = Int(photoPriceTextField.text!),
        image = addedPhotoImageView,
        name = self.photoNameTextField.text!,
        description = self.descriptionTextView.text!,
        stock = self.stock
        
        if price == nil || name == "" || description == "" {
            self.present(UIAlertController.classic(title: "Эттеншн", message: "Вы ввели не все данные. Перепроверьте свой результат"), animated: true)
        }else if image == nil{
            self.present(UIAlertController.classic(title: "Эттеншн", message: "Вы забыли фотографию"), animated: true)
        }else{
            NetworkManager.shared.uploadProductToBackEnd(image: image!, productName: name, progressIndicator: progressView, success: {
                let category = self.selectedCategory,
                subCategory = self.selectedSubCategory
                NetworkManager.shared.uploadProductDescriptionToBackEnd(name: name, price: price ?? 0, description: description, category: category, subCategory: subCategory, stock: stock, searchArray: [name]) {
                    self.present(UIAlertController.alertAppearanceForHalfSec(title: "Готово!", message: "Новый товар добавлен"), animated: true)
                    self.photoNameTextField.text = ""
                    self.descriptionTextView.text = ""
                    self.photoPriceTextField.text = ""
                    self.stockSwitch.isOn = false
                    self.stock = false
                    self.stockConditionLabel.text = "Без акции"
                }
            }) { error in
                print("ERROR: NetworkManager.shared.setupProduct: ", error.localizedDescription)
                self.present(UIAlertController.classic(title: "Внимание", message: "Произошла ошибка: \(error.localizedDescription)"), animated: true)
            }
        }
    }
    
}

//MARK: - Hide Un Hide Any
private extension ProductCustomizeViewController {
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.height - tabBarHeight + 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: false)
        }
    }
    @objc private func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        scrollViewBottomConstraint.constant = 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
}
