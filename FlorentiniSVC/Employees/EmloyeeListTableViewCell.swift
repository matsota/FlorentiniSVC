//
//  EmloyeeListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 17.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

protocol EmloyeeListTableViewCellDelegate: class {
    
    func changeEmployeeposition (_ cell: EmloyeeListTableViewCell)
    
}

class EmloyeeListTableViewCell: UITableViewCell {

    weak var delegate: EmloyeeListTableViewCellDelegate?
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func changeEmployeePositionTapped(_ sender: UIButton) {
        delegate?.changeEmployeeposition(self)
    }

    func fill(name: String, position: String){
        
        nameLabel.text = name
        
        positionButton.setTitle(position, for: .normal)
        
    }
}
