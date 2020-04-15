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
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forViewDidLoad()
        
    }
    
    //MARK: - New Message
    @IBAction private func typeMessage(_ sender: UIButton) {
        guard name != "" else {return}
        self.present(UIAlertController.sendToChat(name: name), animated: true)
    }
    
    //MARK: - Transition Menu Tapped
    @IBAction private func workerMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
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
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissBy: transitionDismissButton)
    }
    
    //MARK: - Private Implementation
    private var currentWorkerInfo = [DatabaseManager.EmployeeData]()
    private var messagesArray = [DatabaseManager.ChatMessages]()
    
    private var name = String()
    private var position = String()
    
    //MARK: TableView Outlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: View
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Button
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    //MARK: Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
    
}









//MARK: - Extensions:

//MARK: - For Overrides
private extension ChatViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {        
        NetworkManager.shared.fetchEmployeeData(success: { workerInfo in
            self.currentWorkerInfo = workerInfo
            self.currentWorkerInfo.forEach { workerInfo in
                self.name = workerInfo.name
                self.position = workerInfo.position
            }
        }) { error in
            print(error.localizedDescription)
        }
        
        //MARK: Сообщения чата
        NetworkManager.shared.fetchEmployeeChat(success: { messages in
            self.messagesArray = messages
            self.tableView.reloadData()
        }) { error in
            print(error.localizedDescription)
        }
        
        //MARK: Обновление чата
        NetworkManager.shared.updateChat { newMessages in
            self.messagesArray.insert(newMessages, at: 0)
            
//            let messageFrom = newMessages.name,
//            messageBody = newMessages.content
//            Notifications.shared.newMessage(messageFrom: messageFrom, messageBody: messageBody, messageSender: self.name)
            
            self.tableView.reloadData()
        }
        
    }
    
}

//MARK: - by TableView
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.ChatTVCell.rawValue, for: indexPath) as! ChatTableViewCell,
        message = messagesArray[indexPath.row]
        
        cell.fill(name: message.name, content: message.content, date: "\(message.timeStamp)")
        
        return cell
    }
    
}

//MARK: -


