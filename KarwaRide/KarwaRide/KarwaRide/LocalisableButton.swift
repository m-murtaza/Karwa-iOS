//
//  LocalisableButton.swift
//  KarwaRide
//
//  Created by Sam Ash on 09/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

class LocalisableButton: UIButton {

    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            UIView.performWithoutAnimation {
                setTitle(key.localized(), for: .normal)
                layoutIfNeeded()
            }
        }
    }

}
