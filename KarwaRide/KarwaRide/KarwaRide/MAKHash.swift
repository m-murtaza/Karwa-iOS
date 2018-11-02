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
    var key : Int64 = 0
    var value : Int64 = 0
    
    public func getKey() -> Int64
    {
        return self.key
    }
    
    public func getValue() -> Int64
    {
        return self.value
    }
    
    init(_ key: Int64, _ value:Int64)
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
        let data = text.suffix(from: text.index(text.startIndex, offsetBy: hashIndex)).lowercased()

        return MAKHash(Int64(keyText)!, Int64(data)!)
    }
}
