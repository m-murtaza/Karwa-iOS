//
//  AESEncryption.swift
//  KarwaRide
//
//  Created by Sam Ash on 2/27/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

class AESEncryption
{
    func testCrypt(data:NSData, keyData:NSData, ivData:NSData) -> String {
        
        var base64cryptString = String()
        let cryptData    = NSMutableData(length: Int(data.length) + kCCBlockSizeAES128)!
        let keyLength              = size_t(kCCKeySizeAES128)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted :size_t = 0
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  keyData.bytes, keyLength,
                                  ivData.bytes,
                                  data.bytes, data.length,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            base64cryptString = cryptData.base64EncodedString(options: .endLineWithLineFeed)
        }
        return base64cryptString
    }
}
