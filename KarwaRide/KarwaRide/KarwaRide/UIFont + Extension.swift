//
//  UIFont + Extension.swift
//  KarwaRide
//
//  Created by Umer Afzal on 28/10/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation


protocol Heading {
  var size: CGFloat {get set}
  var regular: UIFont? {get}
}
extension Heading {
  var extralight: UIFont? {
    UIFont(name: UIFont.MuseoSans.extralight, size: size)
  }
  var light: UIFont? {
    UIFont(name: UIFont.MuseoSans.light, size: size)
  }
  var regular: UIFont? {
    UIFont(name: UIFont.MuseoSans.regular, size: size)
  }
  var meduim: UIFont? {
    UIFont(name: UIFont.MuseoSans.meduim, size: size)
  }
  var bold: UIFont? {
    UIFont(name: UIFont.MuseoSans.bold, size: size)
  }
}
extension UIFont {
  /// size 22
  struct H1: Heading {
    var size: CGFloat = 22.0
  }
  /// size 20
  struct H2: Heading {
    var size: CGFloat = 20.0
  }
  /// size 18
  struct H3: Heading {
    var size: CGFloat = 18.0
  }
  /// size 16
  struct H4: Heading {
    var size: CGFloat = 16.0
  }
  /// size 14
  struct H5: Heading {
    var size: CGFloat = 14.0
  }
  /// size 12
  struct H6: Heading {
    var size: CGFloat = 12.0
  }
  /// size 10.0
  struct H7: Heading {
    var size: CGFloat = 10.0
  }
  /// size 8.0
  struct H8: Heading {
    var size: CGFloat = 8.0
  }
  
  struct MuseoSans {
    static let extralight = "MuseoSans-100"
    static let light = "MuseoSans-300"
    static let regular = "MuseoSans-500"
    static let meduim = "MuseoSans-700"
    static let bold = "MuseoSans-900"
  }
}

extension UIColor {
  static let primary = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
  static let primaryLight = #colorLiteral(red: 0.8980392157, green: 0.9607843137, blue: 0.9490196078, alpha: 1)
  static let secondary = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
  static let background = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.968627451, alpha: 1)
}


