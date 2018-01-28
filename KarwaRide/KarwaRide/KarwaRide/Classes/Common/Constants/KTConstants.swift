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
typealias KTDALCompletionBlock = (_ success: String, _ response: [AnyHashable: Any]) -> Void
typealias KTDALSuccessBlock = (_ response: [AnyHashable: Any],_ success: KTDALCompletionBlock) -> Void
//typealias KTDALCompletionBlock = (_ success: String, _ response: Any) -> Void
//typealias KTDALSuccessBlock = (_ response: Any,_ success: KTDALCompletionBlock) -> Void

enum VehicleType: Int {
    case KTCityTaxi = 1
    case KTAiport7Seater = 3
    case KTAirportSpare = 5
    case KTSpecialNeedTaxi = 10
    case KTAiportTaxi = 11
    case KTCompactLimo = 20
    case KTStandardLimo = 30
    case KTBusinessLimo = 50
    case KTLuxuryLimo = 70
}


struct Constants {
    static let TOSUrl:String = "http://www.karwasolutions.com/tos.htm"

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
        static let SUCCESS = "SUCCESS"
        static let UNKNOWN = "UNKNOWN";
        static let FAILED = "FAILED"
        static let FAILED_DB = "FAILED_DB";
        static let FAILED_API = "FAILED_API";
        static let FAILED_NETWORK = "FAILED_NETWORK"
        static let ALREADY_EXIST = "ALREADY_EXIST"
        static let NOT_FOUND = "NOT_FOUND"
        static let INVALID = "INVALID"
        static let EXCEPTION = "EXCEPTION"
        static let INACTIVE = "INACTIVE"
        static let UNASSIGNED = "UNASSIGNED"
        static let TIMEOUT = "TIMEOUT"
        static let REJECTED = "REJECTED"
        static let PENDING_IMPLEMENTATION = "PENDING_IMPLEMENTATION"
        static let SUSPENDED = "SUSPENDED"
        static let NO_UPDATE = "NO_UPDATE"
        static let UNVERIFIED = "UNVERIFIED"
    }
    
    struct LoginResponseAPIKey {
        static let CustomerType = "CustomerType"
        static let Email = "Email"
        static let Name = "Name"
        static let Phone = "Phone"
        static let SessionID = "SessionID"
    }
    
    struct AddressPickResponseAPIKey {
        static let LocationId = "ID"
        static let Latitude = "Lat"
        static let Longitude = "Lon"
        static let Name = "Name"
        static let Area = "Area"
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
        static let OTP = "Otp"
    }
    
    struct SignUpParams {
        static let Name = "Name"
        static let Phone = "Phone"
        static let Email = "Email"
        static let Password = "Password"
    }
    
    struct APIURL {
        static let Login = "user/login"
        static let GetUserInfo = "user/"
        static let SignUp = "user/"
        static let Otp = "user/otp"
        static let UpdatePass = "user/update"
        static let ForgotPass = "user/pwd"
        static let TrackTaxi = "track/"
        static let AddressPickViaGeoCode = "geocode"
        static let AddressPickViaSearch = "geocode/a"
    }
    
    struct TrackTaxiParams {
        static let Status = "status"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Radius = "Radius"
        static let VehicleType = "type"
        static let Limit  = "limit"
    }
    
    struct AddressPickParams {
        static let Lat = "lat"
        static let Lon = "lon"
        static let Address = "address"
        static let Limit = "limit"
    }
    
    struct DeviceTypes {
        static let iOS = "1"
        static let Android = "2"
        static let Unknown = "0"
    }
    
    struct UpdatePassParam {
        static let Phone = "Phone"
        static let Password = "Password"
    }
}
