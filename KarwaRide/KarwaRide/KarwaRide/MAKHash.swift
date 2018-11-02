//
//  MAKHash.swift
//  KarwaRide
//
//  Created by Sam Ash on 11/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

public class MAKHash
{
    static let VERSION_INFO = "MAK1"
    var key : ULONG = 0
    var value : ULONG = 0
    
    public func getKey() -> ULONG
    {
        return self.key
    }
    
    public func getValue() -> ULONG
    {
        return self.value
    }
    
    init(_ key: ULONG, _ value:ULONG)
    {
        self.key = key
        self.value = value
    }
    
    func toString() -> String
    {
        return MAKHash.VERSION_INFO + String(format:"%08X", key) + String(value)
    }
    
    public static func getMAKHash(_ text: String) -> MAKHash
    {
        let keyLength = 16
        let headerLength = VERSION_INFO.count
        
        let hashIndex = headerLength + keyLength

        let keyText = text.suffix(from: text.index(text.startIndex, offsetBy: headerLength)).lowercased()
        var hash : MAKHash
        let hex = String(format: "%llX", keyText)

        let data = text.suffix(from: text.index(text.startIndex, offsetBy: hashIndex)).lowercased()

        return MAKHash(key, data)
    }
}
