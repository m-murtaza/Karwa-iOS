//
//  ButtonWithShadow.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class ButtonWithShadow: UIButton {
    
    let spacing: CGFloat = 0.69
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(hexString: "#129793").cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 10.0
        //self.layer.sh
        self.layer.masksToBounds = false
        
        //Add spacing
        let color = super.titleColor(for: state) ?? UIColor.white
        let attributedTitle = NSAttributedString(
            string: (self.titleLabel?.text)!,
            attributes: [NSAttributedStringKey.kern: spacing,
                         NSAttributedStringKey.foregroundColor: color])
        super.setAttributedTitle(attributedTitle, for: state)
        
        
        
        /*let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
        self.setAttributedTitle(attributedString, for: .normal)*/
        
    }
    
}

