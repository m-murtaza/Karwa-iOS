//
//  InputFieldUtil.swift
//  KarwaRide
//
//  Created by Sam Ash on 24/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import MaterialComponents

class InputFieldUtil
{
    public static func applyTheme(_ field : MDCFilledTextField, _ isPassword : Bool)
    {
        field.label.font = UIFont(name: "MuseoSans-500", size: 11.0)!
        field.setUnderlineColor(UIColor(hexString: "#005866"), for: .editing)
        field.setUnderlineColor(UIColor(hexString: "#C9C9C9"), for: .normal)
        field.label.textColor = UIColor(hexString: "#6CB1B7")
        field.tintColor = UIColor(hexString: "#6CB1B7")
        field.label.textColor = UIColor(hexString: "#6CB1B7")
        field.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        field.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .editing)
        field.inputView?.tintColor = UIColor(hexString: "#6CB1B7")

        field.isSecureTextEntry = isPassword
    }
}
