//
//  String+Utils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import libPhoneNumber_iOS

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    func isPhoneValid(region: String) -> Bool
    {
        let phoneUtil = NBPhoneNumberUtil()
        var isValidPhone = false

        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(self, defaultRegion: region)
//            let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            isValidPhone = phoneUtil.isValidNumber(phoneNumber)
            print("Phone number is " + (isValidPhone ? "Valid" : "invalid"))
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return isValidPhone
    }
    
    func extractCountryCode() -> String
    {
        let phoneUtil = NBPhoneNumberUtil()
        var nationalNumber:NSString? = nil
        let countryCode = phoneUtil.extractCountryCode(self, nationalNumber: &nationalNumber)
        print(nationalNumber)
        return "\(countryCode ?? 0)"
    }
    
//    var isPhoneNumber: Bool {
//        let numberWithoutPlus = self.replacingOccurrences(of: "+", with: "", options: .literal, range: nil)
//        let PHONE_REGEX = "^[0-9]{0, 14}$"
//
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//        if phoneTest.evaluate(with: numberWithoutPlus)
//        {
//            return true
//        }
//        return false
//    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func urlEncodedString(plainString: String) -> String? {
        
        return plainString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
//    func firstLetter() -> String {
//        return self.characters.startIndex
//    }
    /*func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }*/
    
    func md5() -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func hexadecimal() -> String
    {
        let str = self
        let data = Data(str.utf8)
        let returnValue = data.map{ String(format:"%02x", $0) }.joined()
        return returnValue
    }
    
    func urlEncodeString() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func flag() -> String {
        let country:String = self
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in country.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
  
  func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
    return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
  }
  
  func convertToNumbersIfNeeded() -> String {
    let numberStr: String = self
    let formatter = NumberFormatter()
    formatter.locale = NSLocale(localeIdentifier: "EN") as Locale
    formatter.numberStyle = .decimal
    formatter.decimalSeparator = "."
    if let final = formatter.number(from: numberStr) {
      return final.stringValue
    }
    formatter.decimalSeparator = ","
    if let final = formatter.number(from: numberStr) {
      return final.stringValue
    }
    formatter.decimalSeparator = "٫"
    if let final = formatter.number(from: numberStr) {
      return final.stringValue
    }
    else {
      return numberStr
    }
  }
    
    func base64ToImage() -> UIImage? {
        if let decodedData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return UIImage(data: decodedData)
        }
        return nil
    }
    
    init?(htmlEncodedString: String) {

            guard let data = htmlEncodedString.data(using: .utf8) else {
                return nil
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
                return nil
            }

            self.init(attributedString.string)

        }
}
