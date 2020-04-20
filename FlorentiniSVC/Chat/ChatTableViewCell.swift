//
//  ChatTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    
    //MARK: View
    @IBOutlet weak var messageView: DesignView!
    
    //MARK: Label
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: Constraint
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    //MARK: - Заполнение Таблицы
    func fill(name: String, content: String, date: String) {
        nameLabel?.text = name
        contentLabel?.text = content
        dateLabel?.text = date
        
        if name == CoreDataManager.shared.fetchEmployeeName(failure: { error in
            print("ERROR in ChatTableViewCell with parametrs: name:\(name), time:\(date)", error.localizedDescription)
        }) {
            contentLabel.textColor = UIColor.pinkColorOfEnterprise
            messageView.backgroundColor = UIColor.purpleColorOfEnterprise
            stackViewLeadingConstraint.constant = nameLabel.frame.width
            dateLabel.textAlignment = .right
            nameLabel.isHidden = true
        }else{
            contentLabel.textColor = UIColor.purpleColorOfEnterprise
            messageView.backgroundColor = UIColor.pinkColorOfEnterprise
            stackViewLeadingConstraint.constant = 0
            dateLabel.textAlignment = .left
            nameLabel.isHidden = false
        }
    }
    
}
