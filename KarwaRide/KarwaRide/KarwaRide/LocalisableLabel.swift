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

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 3.0
    @IBInspectable var rightInset: CGFloat = 3.0

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: leftInset, dy: topInset)) //rect.inset(by: insets)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

extension UILabel {
    
    @IBInspectable var genericLocalisedKey: String? {        
        get {
            guard let key = self.genericLocalisedKey else { return ""}
            return  NSLocalizedString(key, comment: "")
        }
        set {
            text = NSLocalizedString(newValue ?? "", comment: "")
        }
        
    }
    
    func addTrailing(image: UIImage, text:String, imageOffsetY: CGFloat) {
        let attachment = NSTextAttachment()
        attachment.image = image
        // Set bound to reposition
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width, height: attachment.image!.size.height)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])
        
        string.append(attachmentString)
        self.attributedText = string
    }
    
    func addLeading(image: UIImage, text:String, imageOffsetY: CGFloat) {
        let attachment = NSTextAttachment()
        attachment.image = image
        // Set bound to reposition
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width, height: attachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)
        let string = NSMutableAttributedString(string: "  "+text, attributes: [:])
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
