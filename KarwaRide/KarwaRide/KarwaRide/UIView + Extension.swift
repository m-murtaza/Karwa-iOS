//
//  UIView + Extension.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

class UIViewWithShadow: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.shadowRadius = 8.0
    layer.shadowOpacity = 0.3
    layer.shadowOffset = CGSize(width: 1, height: 1)
    layer.shadowColor = UIColor.black.cgColor
  }
}

extension UIView {
  
  struct Constants {
    static let ExternalBorderName = "externalBorder"
  }
  
  @discardableResult
  func addExternalBorder(borderWidth: CGFloat = 2.0,
                         borderColor: UIColor = UIColor.white,
                         cornerRadius: CGFloat = 10.0) -> CALayer {
    let externalBorder = CALayer()
    externalBorder.frame = CGRect(x: -borderWidth,
                                  y: -borderWidth,
                                  width: frame.size.width + 2 * borderWidth,
                                  height: frame.size.height + 2 * borderWidth)
    externalBorder.borderColor = borderColor.cgColor
    externalBorder.borderWidth = borderWidth
    externalBorder.name = Constants.ExternalBorderName
    externalBorder.cornerRadius = cornerRadius
    layer.insertSublayer(externalBorder, at: 0)
    layer.masksToBounds = false
    
    return externalBorder
  }
  
  func removeExternalBorders() {
    layer.sublayers?.filter() { $0.name == Constants.ExternalBorderName }.forEach() {
      $0.removeFromSuperlayer()
    }
  }
  
  func removeExternalBorder(externalBorder: CALayer) {
    guard externalBorder.name == Constants.ExternalBorderName else { return }
    externalBorder.removeFromSuperlayer()
  }
  
  
  func applyShadow(radius: CGFloat = 8.0, opacity: Float = 0.3, size: CGSize = CGSize(width: 1, height: 1), color: UIColor = UIColor.black) {
    layer.shadowRadius = radius
    layer.shadowOpacity = opacity
    layer.shadowOffset = size
    layer.shadowColor = color.cgColor
  }
  
  func topTwoRoundedCorners() {
    //self.clipsToBounds = true
    self.layer.cornerRadius = 10
    if #available(iOS 11.0, *) {
      self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    } else {
      // Fallback on earlier versions
    }
  }
  
}


extension UIView {
    
    @IBInspectable
    var customCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var customBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var customBorderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var customShadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var customShadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var customShadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var customShadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UILabel {
  
  // ->1
  enum Direction: Int {
    case topToBottom = 0
    case bottomToTop
    case leftToRight
    case rightToLeft
  }
  
  func startShimmeringAnimation(animationSpeed: Float = 1.4,
                                direction: Direction = .leftToRight,
                                repeatCount: Float = MAXFLOAT) {
    
    // Create color  ->2
    let lightColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1).cgColor
    let blackColor = UIColor.black.cgColor
    
    // Create a CAGradientLayer  ->3
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [blackColor, lightColor, blackColor]
    gradientLayer.frame = CGRect(x: -self.bounds.size.width, y: -self.bounds.size.height, width: 3 * self.bounds.size.width, height: 3 * self.bounds.size.height)
    
    switch direction {
    case .topToBottom:
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
      
    case .bottomToTop:
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
      
    case .leftToRight:
      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
      
    case .rightToLeft:
      gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
    }
    
    gradientLayer.locations =  [0.35, 0.50, 0.65] //[0.4, 0.6]
    self.layer.mask = gradientLayer
    
    // Add animation over gradient Layer  ->4
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [0.0, 0.1, 0.2]
    animation.toValue = [0.8, 0.9, 1.0]
    animation.duration = CFTimeInterval(animationSpeed)
    animation.repeatCount = repeatCount
    CATransaction.setCompletionBlock { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.layer.mask = nil
    }
    gradientLayer.add(animation, forKey: "shimmerAnimation")
    CATransaction.commit()
  }
  
  func stopShimmeringAnimation() {
    self.layer.mask = nil
  }
  
}
