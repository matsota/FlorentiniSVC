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
        
        forViewDidLoad()
        
    }
    
    //MARK: - Transition menu tapped
    @IBAction func transitionMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    
    //MARK: - Transition confirm
    @IBAction func transitionConfirm(_ sender: UIButton) {
        guard let title = sender.currentTitle,
               let view = transitionView,
               let constraint = transitionViewLeftConstraint,
               let button = transitionDismissButton else {return}
               
        transitionPerform(by: title, for: view, with: constraint, dismiss: button)
    }
    
    //MARK: - Transition dismiss
    @IBAction func transitionDismiss(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    //MARK: - Download image by URL
    @IBAction func downLoadByURLTapped(_ sender: UIButton) {
        downloadByURL()
    }
    
    //MARK: - Download from gallery
    @IBAction func galleryTapped(_ sender: UIButton) {
        downLoadPhoto()
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
    private let cases = NavigationCases.CategorySwitch.allCases.map{$0.rawValue}
    private var selectedCategory = NavigationCases.CategorySwitch.none.rawValue
    private let storage = Storage.storage()
    private let storageRef = Storage.storage().reference()
    private let alert = UIAlertController()
    private var givenUrl: URL?
    private var stock = false
    
    //MARK: ImageView
    @IBOutlet private weak var addedPhotoImageView: UIImageView!
    
    //MARK: ScrollView
    @IBOutlet private weak var scrollView: UIScrollView!
    
    //MARK: View
    @IBOutlet weak var transitionView: UIView!
    
    //MARK: Button
    @IBOutlet weak var transitionDismissButton: UIButton!
    
    //MARK: TextField
    @IBOutlet private weak var photoNameTextField: UITextField!
    @IBOutlet private weak var photoPriceTextField: UITextField!
    
    //MARK: TextView
    @IBOutlet private weak var photoDescriptionTextView: UITextView!
    
    //MARK: Label
    @IBOutlet private weak var stockConditionLabel: UILabel!
    
    //MARK: PickerView
    @IBOutlet private weak var photoCategoryPickerView: UIPickerView!
    
    //MARK: Switch
    @IBOutlet private weak var stockSwitch: UISwitch!
    
    //MARK: ProgressView
    @IBOutlet private weak var progressView: UIProgressView!
    
    //MARK: Activity Indicator
    @IBOutlet private weak var imageActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraints
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var transitionViewLeftConstraint: NSLayoutConstraint!
}









//MARK: - Extension:

//MARK: - For Overrides
private extension ProductCustomizeViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {
        imageActivityIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        setTextViewPlaceholder()
    }
    
}

//MARK: - by PickerView
extension ProductCustomizeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == photoCategoryPickerView {return  cases[row]}
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == photoCategoryPickerView {return cases.count}
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == photoCategoryPickerView {
            selectedCategory = cases[row]
        }
    }
    
}

//MARK: - by TextView-Delegate + Custom-for-placeholder
extension ProductCustomizeViewController: UITextViewDelegate {
    
    func setTextViewPlaceholder() {
        photoDescriptionTextView.text = "Введите текст"
        photoDescriptionTextView.textColor = .systemGray4
        photoDescriptionTextView.font = UIFont(name: "System", size: 13)
        
        photoDescriptionTextView.layer.borderWidth = 1
        photoDescriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        photoDescriptionTextView.layer.cornerRadius = 5
        photoDescriptionTextView.returnKeyType = .done
        photoDescriptionTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if photoDescriptionTextView.text == "Введите текст" {
            photoDescriptionTextView.text = ""
            photoDescriptionTextView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
}

//MARK: -

//MARK: - Создание изображение для товара с помощью камеры телефона + с помощью галлереи телефона

extension ProductCustomizeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
    
    func downLoadPhoto() {
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
    
}

//MARK: - Поиск фотографии по ссылке из сети
private extension ProductCustomizeViewController {
    
    func downloadByURL() {
        self.present(UIAlertController.uploadImageURL { url in
            self.imageActivityIndicator.isHidden = false
            self.imageActivityIndicator.startAnimating()
            NetworkManager.shared.downloadImageByURL(url: url) { image in
                self.addedPhotoImageView.image = image
                self.imageActivityIndicator.isHidden = true
                self.imageActivityIndicator.stopAnimating()
            }
        }, animated: true)
    }
    
}

//MARK: - Загрузка продукта в сеть
private extension ProductCustomizeViewController {
    
    func productCreationConfirms() {
        let price = Int(photoPriceTextField.text!),
        image = addedPhotoImageView,
        name = self.photoNameTextField.text!,
        description = self.photoDescriptionTextView.text!,
        category = self.selectedCategory,
        stock = self.stock
        
        if price == nil || name == "" || description == "" {
            self.present(UIAlertController.classic(title: "Эттеншн", message: "Вы ввели не все данные. Перепроверьте свой результат"), animated: true)
        }else if selectedCategory == NavigationCases.CategorySwitch.none.rawValue {
            self.present(UIAlertController.classic(title: "Эттеншн", message: "Вы не выбрали категорию продукта."), animated: true)
        }else if image == nil{
            self.present(UIAlertController.classic(title: "Эттеншн", message: "Вы забыли фотографию"), animated: true)
        }else{
            NetworkManager.shared.setupProduct(image: image!, productName: name, progressIndicator: progressView, success: {
                NetworkManager.shared.setupProductDescription(productName: name, productPrice: price ?? 0, productDescription: description, productCategory: category, stock: stock, searchArray: [name]) {
                    self.present(UIAlertController.completionDoneHalfSec(title: "Готово!", message: "Новый товар добавлен"), animated: true)
                    self.photoNameTextField.text = ""
                    self.photoDescriptionTextView.text = ""
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

//MARK: - Keyboard
private extension ProductCustomizeViewController {
    
    //Movement constrains for keyboard
    @objc private func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        scrollViewBottomConstraint.constant = -keyboardFrameValue.cgRectValue.height
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
