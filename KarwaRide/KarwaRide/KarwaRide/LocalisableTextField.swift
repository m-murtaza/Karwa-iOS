//
//  LocalisableTextField.swift
//  KarwaRide
//
//  Created by Sam Ash on 22/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

class LocalisableTextField: UITextField {

    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            placeholder = key.localized()
            text = key.localized()
        }
    }

}
