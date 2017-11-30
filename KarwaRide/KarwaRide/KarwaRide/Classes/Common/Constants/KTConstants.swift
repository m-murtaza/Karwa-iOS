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
}
