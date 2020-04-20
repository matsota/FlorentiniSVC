//
//  View + IBDesignable.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 20.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit


@IBDesignable
class DesignView: UIView {
    
    @IBInspectable var rounding: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = rounding
        }
    }

}
