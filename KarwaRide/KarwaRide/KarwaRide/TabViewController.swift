//
//  TabViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 14/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor(hexString: "#006170"), NSAttributedStringKey.font : UIFont(name: "MuseoSans-500", size: 10.0)!], for: .normal)

        self.tabBar.unselectedItemTintColor = UIColor(hexString: "#65A0AA")

    }
    
}
