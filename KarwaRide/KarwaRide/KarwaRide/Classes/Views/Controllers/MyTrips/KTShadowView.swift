//
//  KTShadowView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
open class KTShadowView: ViewWithRoundCorner {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
    //override func draw(_ rect: CGRect) {
        //let currentContext: CGContext? = UIGraphicsGetCurrentContext()
        //currentContext?.saveGState()
        //CGContextSetShadow(currentContext!, CGSize(width: -15, height: 20), 5)
        //CGContext.setShadow(currentContext!,offset: CGSize(width: -15, height: 20), blur: 5)
        //currentContext!.setShadow(offset: CGSize(width: -15, height: 20), blur: 5)
        //super.draw(rect)
        //currentContext?.restoreGState()
    //}
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }
    
    /*@IBInspectable var shadowBlur: Double {
        get {
            return Double(self.layer.shadow)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }*/
}
