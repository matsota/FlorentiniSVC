//
//  EmloyeeListTableViewCell.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 17.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class EmloyeeListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func fill(name: String, position: String){
        
        nameLabel.text = name
        positionLabel.text = position
        
    }
}
