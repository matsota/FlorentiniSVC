//
//  ChatViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import UserNotifications

class ChatViewController: UIViewController {
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forViewDidLoad()
        
    }
    
    //MARK: - Transition Menu Tapped
    @IBAction private func transitionMenuTapped(_ sender: UIButton) {
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
    @IBAction private func transitionDismissTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    //MARK: - New Message
    @IBAction private func typeMessage(_ sender: UIButton) {
        guard name != "" else {
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Ошибка Аутентификации"), animated: true)
            return
        }
        if let content = self.chatTextView.text {
            NetworkManager.shared.newChatMessage(name: self.name, content: content, position: position)
            self.chatTextView.text = ""
            self.textViewDidEndEditing(self.chatTextView)
        }
    }
    
    //MARK: - Private Implementation
    private var currentWorkerInfo = [DatabaseManager.EmployeeDataStruct]()
    private var messagesArray = [DatabaseManager.ChatMessages]()
    
    private var name = String()
    private var position = String()
    
    
    
    
    //0.831494 0.711081 0.831399
    
    //MARK: TableView Outlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: View
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Text View
    @IBOutlet private weak var chatTextView: UITextView!
    
    
    //MARK: Button
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    //MARK: Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var forKeyboardBottomConstraint: NSLayoutConstraint!
    
}









//MARK: - Extensions:

//MARK: - For Overrides
private extension ChatViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {        
        
        NetworkManager.shared.downloadEmployeeChat(success: { messages in
            self.messagesArray = messages
            self.messagesArray.reverse()
            self.tableView.reloadData()
        }) { error in
            print("ERROR: ChatViewController/viewDidLoad/fetchChat: ",error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Произошла ошибка. Возможно пропал интеренет"), animated: true)
        }
        
        //MARK: Обновление чата
        NetworkManager.shared.chatListener { newMessages in
            self.messagesArray.insert(newMessages, at: 0)
            
            //            let messageFrom = newMessages.name,
            //            messageBody = newMessages.content
            //            Notifications.shared.newMessage(messageFrom: messageFrom, messageBody: messageBody, messageSender: self.name)
            
            self.tableView.reloadData()
        }
        
        self.name = CoreDataManager.shared.fetchEmployeeName(failure: { (_) in
            
        })
        self.position = CoreDataManager.shared.fetchEmployeePosition(failure: { (_) in
            
        })
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        setTextViewPlaceholder(for: chatTextView)
        
    }
    
}

//MARK: - by TableView
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.ChatTVCell.rawValue, for: indexPath) as! ChatTableViewCell,
        message = messagesArray[indexPath.row],
        date = Date.asString(message.timeStamp)(),
        position = message.position
        
        cell.fill(name: message.name, content: message.content, position: position, date: date)
        
        return cell
    }
    
}

//MARK: - Hide Unhide Any
extension ChatViewController {
    
    // - show keyboard
    @objc func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        forKeyboardBottomConstraint.constant = keyboardFrameValue.cgRectValue.height
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    // - hide keyboard
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        forKeyboardBottomConstraint.constant = 0
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - TextView Delegate + Custom
extension ChatViewController: UITextViewDelegate {
    
    private func setTextViewPlaceholder(for textView: UITextView) {
        textView.text = "Введите текст"
        textView.textColor = .systemGray4
        textView.font = UIFont(name: "System", size: 13)
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 5
        textView.returnKeyType = .done
        textView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите текст" {
            textView.text = ""
            textView.textColor = UIColor.purpleColorOfEnterprise
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Введите текст"
            textView.textColor = .systemGray4
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
}


