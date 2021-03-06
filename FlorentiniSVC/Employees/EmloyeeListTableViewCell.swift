//
//  EmloyeeListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 17.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

protocol EmloyeeListTableViewCellDelegate: class {
    
    func changeEmployeePosition (_ cell: EmloyeeListTableViewCell)
    
}

class EmloyeeListTableViewCell: UITableViewCell {

    var uid: String?
    var name: String?
    weak var delegate: EmloyeeListTableViewCellDelegate?
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionButton: UIButton!
    @IBOutlet private weak var noEmployeeDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func changeEmployeePositionTapped(_ sender: UIButton) {
        delegate?.changeEmployeePosition(self)
    }

    func fill(name: String, position: String, uid: String){
        
        self.name = name ; self.uid = uid
        
        nameLabel.text = name
        positionButton.setTitle(position, for: .normal)
        
    }
}
