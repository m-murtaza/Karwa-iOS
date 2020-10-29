//
//  UIViewController + Extension.swift
//  KarwaRide
//
//  Created by Umer Afzal on 29/10/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func tapToDismissKeyboard() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(dismissKeyboardOld))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboardOld() {
    view.endEditing(true)
  }
}
