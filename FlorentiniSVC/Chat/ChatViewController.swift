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
        
        // - network
        NetworkManager.shared.downloadEmployeeChat(success: { messages in
            self.messagesArray = messages
            self.messagesArray.reverse()
            self.tableView.reloadData()
        }) { error in
            print("ERROR: ChatViewController/viewDidLoad/fetchChat: ",error.localizedDescription)
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Произошла ошибка. Возможно пропал интеренет"), animated: true)
        }
        NetworkManager.shared.chatListener { newMessages in
            self.messagesArray.insert(newMessages, at: 0)
 //            let messageFrom = newMessages.name,
 //            messageBody = newMessages.content
 //            Notifications.shared.newMessage(messageFrom: messageFrom, messageBody: messageBody, messageSender: self.name)
            self.tableView.reloadData()
        }
        
        // - coredata
        self.name = CoreDataManager.shared.fetchEmployeeName()
        self.position = CoreDataManager.shared.fetchEmployeePosition()
        self.uid = CoreDataManager.shared.fetchEmployeeUID()
        
        // - keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        
        // - textview
        cutomsTextView(for: chatTextView, placeholder: "Введите Сообщение")
        chatTextView.delegate = self
        
    }
    
    //MARK: - New Message
    @IBAction private func typeMessage(_ sender: UIButton) {
        guard name != "" else {
            self.present(UIAlertController.alertAppearanceForTwoSec(title: "Внимание", message: "Ошибка Аутентификации"), animated: true)
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
    private var uid = String()
    
    
    
    
    //0.831494 0.711081 0.831399
    
    //MARK: TableView Outlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Text View
    @IBOutlet private weak var chatTextView: UITextView!
    
    //MARK: Constraint
    @IBOutlet private weak var forKeyboardBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    
}









//MARK: - Extensions:

//MARK: - TableView
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

//MARK: - TextView Delegate + Custom
extension ChatViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите Сообщение" {
            textView.text = ""
            textView.textColor = UIColor.purpleColorOfEnterprise
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Введите Сообщение"
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

//MARK: - Hide Unhide Any
extension ChatViewController {
    
    // - show keyboard
    @objc func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
        let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        
        let height = keyboardFrameValue.cgRectValue.height - tabBarHeight + 14
        forKeyboardBottomConstraint.constant = height
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    // - hide keyboard
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        forKeyboardBottomConstraint.constant = 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}


