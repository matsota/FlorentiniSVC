//
//  TabBarViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 09.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.purpleColorOfEnterprise
        self.selectedIndex = 2
    }
    

}
