//
//  UITableView+Extension.swift
//  KarwaRide
//
//  Created by Piecyfer on 23/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

extension UITableView{
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "MuseoSans-500", size: 14.0)!
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
}
