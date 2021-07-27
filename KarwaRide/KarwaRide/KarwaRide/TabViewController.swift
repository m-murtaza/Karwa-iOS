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
        
        tabBar.selectionIndicatorImage = UIImage(named: "active_tab_bg")!
            .resizableImage(withCapInsets: UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0))
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 3
        tabBar.frame.origin.x = -2
        
        tabBar.customShadowRadius = 3
        tabBar.customShadowOpacity = 1
        tabBar.customShadowOffset = CGSize(width: 1, height: 0)
        tabBar.customShadowColor = UIColor.black.withAlphaComponent(0.7)
        
    }
    
}

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: -3.0, width: Double(size.width), height: Double(5))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
