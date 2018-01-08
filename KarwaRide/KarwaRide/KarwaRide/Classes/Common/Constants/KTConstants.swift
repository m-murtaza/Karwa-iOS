//
//  AppConstants.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

//import UIKit
//
//class AppConstants: NSObject {
//
//    let KEY_BASE_URL = "BaseAPIURL"
//}

typealias KTResponseCompletionBlock = (_ success: Bool, _ response: [AnyHashable: Any]) -> Void


struct Constants {
    struct API {
        static let BaseURLKey = "BaseAPIURL"
        static let RequestTimeOut = 10.0
    }
    
    struct ResponseAPIKey {
        static let Data = "D"
        static let Status = "S"
        static let MessageDictionary = "E"
        static let Message = "M"
        static let Title = "T"
    }
    
    struct APIResponseStatus {
        static let Success = "SUCCESS"
    }
    
    struct LoginResponseAPIKey {
        static let CustomerType = "CustomerType"
        static let Email = "Email"
        static let Name = "Name"
        static let Phone = "Phone"
        static let SessionID = "SessionID"
    }
    
    
    struct KTAPIStatus : OptionSet {
        let rawValue: Int
        
        static let unknownError = KTAPIStatus(rawValue: 0)
        // Generic Error
        static let success = KTAPIStatus(rawValue: 1)
        // Success Case
        static let userNotRegistered = KTAPIStatus(rawValue: 2)
        // Mobile number provided doesn't exist in DB
        static let userAlreadyRegistered = KTAPIStatus(rawValue: 3)
        
    }
    
    struct LoginParams {
        static let Phone = "Phone"
        static let Password = "Password"
        static let DeviceType = "DeviceType"
        static let DeviceToken = "DeviceToken"
    }
    
    struct APIURL {
        static let Login = "user/login"
        static let GetUserInfo = "user/"
    }
    
    struct DeviceTypes {
        static let iOS = "1"
        static let Android = "2"
        static let Unknown = "0"
        
    }
}
