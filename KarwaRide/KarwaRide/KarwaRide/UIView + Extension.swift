//
//  UIView + Extension.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

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


