//
//  LocalisableLabel.swift
//  KarwaRide
//
//  Created by Sam Ash on 09/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

class LocalisableLabel: UILabel {

    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }

}

// MARK: Special protocol to localizaze UI's placeholder
public protocol UIPlaceholderXIBLocalizable {
    var localePlaceholderKey: String? { get set }
}

extension UITextField: UIPlaceholderXIBLocalizable {

    @IBInspectable public var localePlaceholderKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized()
        }
    }

}

extension UISearchBar: UIPlaceholderXIBLocalizable {

    @IBInspectable public var localePlaceholderKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized()
        }
    }

}
