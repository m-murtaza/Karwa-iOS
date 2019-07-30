//
//  KTTipTagButton.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/30/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import UIKit

class KTTripTagButton: UIButton {
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //Drawing code
        self.layer.cornerRadius = 23
        self.layer.borderWidth = 1
        self.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 16.0)!
        self.titleLabel?.textColor = UIColor(hexString:"#979899")
        var bgColor : UIColor = UIColor(hexString:"#979899")
        if isSelected
        {
            self.titleLabel?.textColor = UIColor(hexString:"#FFFFFF")
            bgColor = UIColor(hexString:"#5B5A5A")
        }
        else
        {
            self.titleLabel?.textColor = UIColor(hexString:"#979899")
            bgColor = UIColor(hexString:"#FFFFFF")
        }

        self.layer.backgroundColor = bgColor.cgColor
        bgColor.setFill()
    }
    
    func setStrokeColor(hexColor color : String)
    {
        self.layer.borderColor = UIColor(hexString:color).cgColor
    }
    
    var isComplainable = false
    
    func setComplainable(_ isComplainable: Bool)
    {
        self.isComplainable = isComplainable
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                self.runBubbleAnimation()
                
            }
        }
    }
    //  Converted to Swift 4 by Swiftify v4.1.6680 - https://objectivec2swift.com/
    
    func runBubbleAnimation() {
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {() -> Void in
            self.transform = .identity
        })
    }
    
}
