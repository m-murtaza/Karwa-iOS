//
//  MAKHash.swift
//  KarwaRide
//
//  Created by Asif Kamboh in C#
//  Converted by Sam on 11/2/18
//  Copyright © 2018 Karwa. All rights reserved.
//

class MAKHashGenerator {
	static let VERSION_INFO = "MAK1"

	//Date to milliseconds
	func currentTimeInMiliseconds(date: Date) -> UInt64
    {
    		let currentDate = date
    		let since1970 = currentDate.timeIntervalSince1970
    		return UInt64(since1970 * 1000)
	}

    //Date to milliseconds
    func currentTimeInSeconds(date: Date) -> UInt64
    {
        let currentDate = date
        let since1970 = currentDate.timeIntervalSince1970
        return UInt64(since1970)
    }
    
	public func generateKey(date: Date) -> UInt64
    {
		var dateComponents = DateComponents()
		dateComponents.year = 2015
		dateComponents.month = 1 
		dateComponents.day = 1
		
		// Create date from components
		let userCalendar = Calendar.current // user calendar
		let d = userCalendar.date(from: dateComponents)
        let t: UInt64 = currentTimeInMiliseconds(date: d!)
		let b0: UInt64 = ( t & 0xf000000000000000)
		let b1: UInt64 = ( t & 0x0fffffffff000000) >> 24
		let b2: UInt64 = ( t & 0x0000000000ffffff) << 36
		let key: UInt64 = ( b0 | b1 | b2 )
		return 	key		
	}


	func getKeyFromString(text:String) -> UInt64
    {
//        let keyLength = 16
//        let headerLength = MAKHashGenerator.VERSION_INFO.count
        
        let index2 = text.index(text.startIndex, offsetBy: 20)
        
        let keyText = text[text.index(text.startIndex, offsetBy: 4)..<index2]
        
//        let data = Data(keyText.utf8)
//        let hexString = data.map{ String(format:"%02x", $0) }.joined()

        let number = UInt(keyText, radix: 16)!
        print(number)
        
        return UInt64(number)
	}

    func getHashFromString(text: String) -> String
    {
		let keyLength = 16
        let headerLength = MAKHashGenerator.VERSION_INFO.count
		
		let hashIndex = headerLength + keyLength
		let data = String(text.suffix(from: text.index(text.startIndex, offsetBy: hashIndex)))
		return data
	}

    public func decrypt(text: String) -> String
    {
        let key = getKeyFromString(text: text)
        let value = getHashFromString(text: text)
        let keyHash: UInt64 = decryptKey(key: key)
        let decrypted = decryptHash(data: value, key: keyHash)
		return decrypted
			
	}
	func decryptKey(key: UInt64) -> UInt64
    {
		let v: UInt64 = key
		let b0 = (v & 0xf000000000000000)
		let b1 = (v & 0x0000000fffffffff) << 24
		let b2 = (v & 0x0ffffff000000000) >> 36
		let t1 = b0 | b1 | b2
		return t1 
	}

	func decryptHash(data: String, key: UInt64) -> String
    {
        let seconds: UInt64 = getSeconds(millis: key)
		let high: UInt64 = (seconds & 0x7f00) >> 8
		let low : UInt64 = (seconds & 0x007f)
	
		let decodedData = Data(base64Encoded: data)!

        let bytes: [UInt8]  = Array(decodedData) // bytes should be utf8 data
		let max = bytes.count / 2
        var outBytes = [UInt8]()
        for i in 0 ... max - 1
        {
            let b1: UInt8 = bytes[2 * i]
            let b2: UInt8 = bytes[2 * i + 1]
            let c: UInt8
            if i % 2 > 0
            {
                c = UInt8(UInt64(b2) ^ high)
            }
            else
            {
                c = UInt8(UInt64(b1) ^ low)
            }
            
            outBytes.append(c)
        }
        outBytes.reverse()
		let decrypted = String(data: Data(outBytes), encoding:.ascii)
        return decrypted!
	}
	
	func getSeconds(millis: UInt64) -> UInt64
    {
		let day = 3600 * 24 * 1000
		let divider = 1000.0 * 10.0
		let seconds = UInt64(Double(Int(millis) % day)/divider)
		return seconds
	}

}
