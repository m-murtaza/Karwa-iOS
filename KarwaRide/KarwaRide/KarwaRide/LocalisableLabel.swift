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
    
    func addTrailing(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        // Set bound to reposition
        let imageOffsetY: CGFloat = -5.0
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width, height: attachment.image!.size.height)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])
        
        string.append(attachmentString)
        self.attributedText = string
    }
    
    func addLeading(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        // Set bound to reposition
        let imageOffsetY: CGFloat = -4.0
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width, height: attachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)
        let string = NSMutableAttributedString(string: text, attributes: [:])
        mutableAttributedString.append(string)
        self.attributedText = mutableAttributedString
    }
    
    func addImageWith(name: String, behindText: Bool) {
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
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
