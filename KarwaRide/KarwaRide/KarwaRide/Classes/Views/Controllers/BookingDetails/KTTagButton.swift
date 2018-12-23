//
//  KTTagButton.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/18/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
//import Cocoa

class KTTagButton: UIButton {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         //Drawing code
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 9.0)!
        var bgColor : UIColor = UIColor(hexString:"#5B5A5A")
        if isSelected
        {
            if(isComplainable)
            {
                bgColor = UIColor(hexString:"#25AAF1")
            }
            else
            {
                bgColor = UIColor(hexString:"#5B5A5A")
            }
        }
        else
        {
            bgColor = UIColor(hexString:"#FFFFFF")
        }
        
        if(isComplainable)
        {
            self.layer.borderColor = UIColor(hexString:"#25AAF1").cgColor
        }
        else
        {
            self.layer.borderColor = UIColor(hexString:"#5B5A5A").cgColor
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
