//
//  ViewWithRoundCorner.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

@IBDesignable
open class ViewWithRoundCorner: UIView {
    
//    override open func draw(_ rect: CGRect) {
//        super.draw(rect)
//        //updateLayerProperties()
//        self.cornerRadius = 14.0
//    }
//
//    func updateLayerProperties() {
////        self.layer.borderColor = UIColor.darkGray.cgColor
////        self.layer.borderWidth = 1.0
////        self.layer.backgroundColor = UIColor.lightGray.cgColor
//
//    }
    @IBInspectable
    public var cornerRadius: CGFloat = 2.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
