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

typealias KSResponseCompletionBlock = (_ success: Bool, _ response: Any) -> Void


struct Constants {
    struct API {
        static let BaseURLKey = "BaseAPIURL"
        static let RequestTimeOut = 10.0
    }
    
    struct KSAPIStatus : OptionSet {
        let rawValue: Int
        
        static let unknownError = KSAPIStatus(rawValue: 0)
        // Generic Error
        static let success = KSAPIStatus(rawValue: 1)
        // Success Case
        static let userNotRegistered = KSAPIStatus(rawValue: 2)
        // Mobile number provided doesn't exist in DB
        static let userAlreadyRegistered = KSAPIStatus(rawValue: 3)
        
    }
    
    struct LoginParams {
        static let Phone = "Phone"
        static let Password = "Password"
        static let DeviceType = "DeviceType"
        static let DeviceToken = "DeviceToken"
    }
    
    struct APIURL {
        static let Login = "213/user/login"
    }
}
