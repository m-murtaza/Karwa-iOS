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


enum VehicleType: Int16 {
    case Unknown = -1
    case KTCityTaxi = 1
    case KTCityTaxi7Seater = 11
    case KTAiport7Seater = 3
    case KTAirportSpare = 5
    case KTSpecialNeedTaxi = 60
//    case KTAiportTaxi = 11
    case KTCompactLimo = 20
    case KTStandardLimo = 30
    case KTBusinessLimo = 50
    case KTLuxuryLimo = 70
}

enum geoLocationType : Int32 {
    case Unknown = 0
    case Home = 5
    case Work = 6
    case Recent = 10
    case Nearby = 11
    case Popular = 12
}

enum CustomerType : Int32 {
    
    case STANDARD = 1
    case VVIP = 2
    case VIP = 3
    case MOWASALAT_EMPLOYEE = 4
    case PRIORITY_CUSTOMER = 5
    case SPECIAL_NEED = 6
    case JINXED = 7
    case CORPORATE = 100
}

enum BookingStatus : Int32 {
    
    case PENDING = 1
    case DISPATCHING = 2
    case CONFIRMED = 4
    
    /// <summary>
    /// To be sent to customer if even after Manual dispatch a taxi is not made available for customer.
    /// </summary>
    case TAXI_UNAVAIALBE = 10
    
    /// <summary>
    /// To be used if dipatch engine fails to find a taxi. Meant to be Manually dipatched.
    /// </summary>
    case TAXI_NOT_FOUND = 11
    
    /// <summary>
    /// Bidding was done for this booking but no taxi accepted it. Meant to be manually dispatched.
    /// </summary>
    case NO_TAXI_ACCEPTED = 12
    case CANCELLED = 20
    case ARRIVED = 24
    case PICKUP = 25
    case COMPLETED = 30
    
    case EXCEPTION = 33
    case UNKNOWN = 0
}

struct Constants {
    static let TOSUrl:String = "https://www.karwa.qa/tos.html"
    static let ShareTripUrl:String = "https://app.karwatechnologies.com/track/"
    static let ScanNPayTripUrl:String = "https://app.karwatechnologies.com/download/"

    /*                Live Payment Credentials                            */
//    static let MERCHANT_ID:String = "KTRQNB01"
//    static let GATEWAY_REGION:GatewayRegion = GatewayRegion.asiaPacific
    static let DIRECTIONS_API_ENABLE:Bool = false
    /* ------------------------------------------------------------------ */
    
    
    /*                Test Payment Credentials                            */
    static let MERCHANT_ID:String = "KTQNB01A"
    static let GATEWAY_REGION:GatewayRegion = GatewayRegion.mtf
//    static let MERCHANT_ID:String = "TESTMOWKAREVL01"
//    static let DIRECTIONS_API_ENABLE:Bool = false
    /* ------------------------------------------------------------------ */
    
    static let TIP_OPTIONS = ["  QR 2  ", "  QR 3  ", "  QR 5  ", "  QR 10 "]
    static let TIP_OPTIONS_VALUES = ["2", "3", "5", "10"]
    
    
    static let SCAN_N_PAY_ENABLE:Bool = true
    static let SERVER_DATE_FORMAT: String = "yyyy-MM-dd'T'HH:mm:ss"
    static let SERVER_DATE_FORMAT_WITHOUT_T: String = "yyyy-MM-dd HH:mm:ss"
    static let SERVER_DATE_ONLY_FORMAT: String = "dd-MM-yyyy"
    
    static let GOOGLE_DIRECTION_API_KEY: String = "AIzaSyBuQWTg0UryYGD0uPyUQI6RKk08kvZ0fgY"
    static let GOOGLE_SNAPTOROAD_API_KEY : String = "AIzaSyA5Hhmo5hrizljm-ypYDk4mLKT54sM_Y7A"
    //static let GOOGLE_SNAPTOROAD_API_KEY : String = "AIzaSyDorclvVWhNvrFshylfWcRK1iCN03N4KuM"
    
    static let MIN_PASSWORD_LENGTH : Int = 6
    
    static let APP_REQUIRE_VEHICLE_UPDATE_VERSION : Int = 131
    
    struct StoryBoardId {
        static let LeftMenu = "LeftMenuViewController"
        static let LoginView = "FirstViewController"
        static let DetailView = "BookingDetailNavController"
        static let PaymentMethodsNavId = "PaymentMethodsNavController"
        static let PaymentMethodsView = "KTPaymentViewControllerIdentifier"
        static let PaymentNavigationController = "PaymentNavigationController"
        static let TrackTripNavController = "TrackTripNavController"
    }
    
    struct Notification {
        static let MinuteChanged = "MinuteChangedNotification"
        static let LocationManager = "LocationManagerNotificationIdentifier"
        static let UserLogin = "UserLoginNotificationIdentifire"
    }
    
    struct API {
        static let BaseURLKey = "BaseAPIURL"
        static let RequestTimeOut = 10.0
        static let Salt = "Salt"
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
        static let UNKNOWN = "UNKNOWN"
        static let FAILED = "FAILED"
        static let FAILED_DB = "FAILED_DB"
        static let FAILED_API = "FAILED_API"
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
        static let VALIDATE_EMAIL = "VALIDATE_EMAIL"
    }
    
    struct LoginResponseAPIKey {
        static let CustomerType = "CustomerType"
        static let Email = "Email"
        static let Name = "Name"
        static let CountryCode = "CountryCode"
        static let Phone = "Phone"
        static let SessionID = "SessionID"
        static let MaskedEmail = "MaskedEmail"
    }
    
    struct GeoLocationResponseAPIKey {
        static let LocationId = "ID"
        static let Latitude = "Lat"
        static let Longitude = "Lon"
        static let Name = "Name"
        static let Area = "Area"
        static let LocationType = "Type"
    }
    
    struct BookmarkResponseAPIKey {
        static let Name = "Name"
        static let Address = "Address"
        static let Latitude = "Lat"
        static let Longitude = "Lon"
        static let Place =  "Place"
    }
    
    struct ComplaintsResponseAPIKey {
        static let IssueId = "IssueID"
        static let Issue = "Issue"
        static let CategoryId = "CategoryID"
        static let ComplaintType = "ComplaintType"
        static let Name = "Name"
        static let Order =  "Order"
        static let BookingId =  "bookingId"
        static let Remarks =  "remarks"
    }

    struct PaymentResponseAPIKey {
        static let Id = "Id"
        static let Source = "Source"
        static let PaymentType = "Type"
        static let LastFourDigits = "LastFourDigits"
        static let ExpiryMonth = "ExpiryMonth"
        static let ExpiryYear = "ExpiryYear"
        static let Brand =  "Brand"
        static let Balance =  "Balance"
        static let IsRemovable =  "IsRemovable"
        static let SessionId = "SessionId"
        static let ApiVersion = "ApiVersion"
    }
    
    struct PayTripAPIKey {
        static let Data = "Data"
        static let Source = "Source"
        static let DriverId = "DriverId"
        static let PaymentMethodId = "PaymentMethodId"
        static let PaymentToken = "PaymentToken"
        static let PaymentMethod = "PaymentMethod"
        static let TotalFare = "TotalFare"
        static let TripId = "TripId"
        static let TripType = "TripType"
        static let Tip = "Tip"
        static let Remarks = "Remarks"
        static let U =  "UnitNo"
        static let S =  "TripStartTime"
        static let E =  "TripEndTime"
    }
    
    struct MPGSSessionAPIKey {
        static let SessionId = "SessionId"
        static let ApiVersion = "ApiVersion"
    }
    
    struct BookingResponseAPIKey {
        static let BookingID = "BookingID"
        static let BookingStatus = "BookingStatus"
        static let CancelReason = "CancelReason"
        static let CreationTime = "CreationTime"
        static let CallerID = "CallerID"
        
        static let DriverID = "DriverID" 
        static let DriverName = "DriverName"
        static let DriverPhone = "DriverPhone"
        static let DriverRating = "DriverRating"
        
        static let DropAddress = "DropAddress"
        static let DropLat = "DropLat"
        static let DropLon = "DropLon"
        static let DropTime = "DropTime"
        
        static let EstimatedFare = "EstimatedFare"
        static let Eta = "Eta"
        static let Fare = "Fare"
        static let Tip = "DriverTip"
        
        static let Estimates = "Estimates"
        static let EncodedPath = "EncodedPath"
        static let PickupAddress = "PickupAddress"
        static let PickupLat = "PickupLat"
        static let PickupLon = "PickupLon"
        static let PickupMessage = "PickupMessage"
        static let PickupTime = "PickupTime"
        
        static let ServiceType = "ServiceType"
        static let TotalDistance = "TotalDistance"
        static let Track = "Track"
        
        static let VehicleNo = "VehicleNo"
        static let VehicleType = "VehicleType"

        static let TripSummary = "OrderedTripSummary"
        
        static let IsRated = "IsRated"
        
        static let PaymentMethod = "PaymentMethod"
        static let LastFourDigits = "LastFourDigits"
        
        static let TrackId = "TrackID"
        static let TripType = "TripType"
    }
    
    struct GetEstimateResponseAPIKey {
        static let EstimateId = "EstimateId"
        static let VehicleType = "VehicleType"
        static let EstimatedFare = "EstimatedFare"
        static let IsPromoApplied = "IsPromoApplied"
    }
    
    struct CancelReasonAPIKey {
        static let BookingStatii = "BookingStatii"
        static let Desc = "Desc"
        static let EN = "EN"
        static let ReasonCode = "ReasonCode"
    }
    
    struct RatingReasonAPIKey {
        static let Ratings = "Ratings"
        static let Desc = "Desc"
        static let EN = "EN"
        static let ReasonCode = "ReasonCode"
        static let ComplainableRating = "ComplainableRating"
        static let IsComplainable = "isComplainable"
    }
    
    struct NotificationKey {
        static let BookingId = "BookingID"
        static let BookingStatus = "BookingStatus"
        static let NotificationTime = "Time"
        static let RootNotificationKey = "aps"
        static let Message = "alert"
    }
    
    struct BookmarkName {
        static let Home = "home"
        static let Work = "work"
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
        static let CountryCode = "CountryCode"
        static let Phone = "Phone"
        static let Password = "Password"
        static let DeviceType = "DeviceType"
        static let DeviceToken = "DeviceToken"
        static let OTP = "Otp"
    }
    
    struct DeviceTokenParam {
        static let DeviceToken = "DeviceToken"
    }
    
    struct SignUpParams {
        static let Name = "Name"
        static let Phone = "Phone"
        static let Email = "Email"
        static let Password = "Password"
    }
    
    struct BookingParams {
        static let BookingId = "BookingID"
        static let PickLocation = "PickupAddress"
        static let PickLat = "PickupLat"
        static let PickLon = "PickupLon"
        static let PickLocationID = "PickupLocationID"
        static let PickTime = "PickupTime"
        static let DropLat = "DropLat"
        static let DropLon = "DropLon"
        static let DropLocationId = "DropLocationID"
        static let DropLocation = "DropAddress"
        static let CreationTime = "CreationTime"
        static let PickHint = "PickupMessage"
        static let VehicleType = "VehicleType"
        static let CallerID = "CallerID"
        static let Status = "BookingStatus"
        static let BookingType = "BookingType"
        static let EstimateId = "EstimateId"
        static let EstimatedFare = "EstimatedFare"
        static let TrackId = "TrackID"
        static let TripType = "TripType"
        static let PromoCode = "promoCode"
        //static let BookingType = "BookingType"
    }
    
    struct RatingParams {
        static let Rating = "Rating"
        static let Reasons = "Reasons"
        static let TripType = "TripType"
        static let Remarks = "Remarks"
    }
    
    struct ComplaintParams {
        static let IssueID = "IssueID"
        static let CategoryID = "CategoryID"
        static let ComplaintType = "ComplaintType"
        static let Name = "Name"
        static let Order = "Order"
        static let bookingId = "bookingId"
        static let remarks = "remarks"
        static let TripType = "TripType"
    }
    
    struct APIURL {
        static let Login = "user/login"
        static let Logout = "user/logout"
        static let GetUserInfo = "user/"
        static let SignUp = "user/"
        static let Otp = "user/otp"
        static let ResendOtp = "user/resendotp"
        static let UpdateUserAccount = "user/update"
        static let ResendEmail = "user/verify/resend"
        static let ForgotPass = "user/recover"
        static let TrackTaxi = "track/"
        static let AddressPickViaGeoCode = "geocode"
        static let AddressPickViaSearch = "geocode/name"
        static let getAllAddress = "geocode/all"
        static let Booking = "booking"
        static let Track = "booking/track"
        static let GetBookmark = "bookmarks/personal"
        static let SetHomeBookmark = "bookmark/personal/home"
        static let SetWorkBookmark = "bookmark/personal/work"
        static let trackVechicle = "track/job"
        static let initTariff = "tariff/init"
        static let GetEstimate = "tariff/estimate"
        static let GetPromoEstimate = "tariff/estimate"
        static let CancelReason = "booking/cancelreasons"
        static let RatingReason = "booking/ratingreasons"
        static let RateBooking = "booking/rate"
        static let DriverImage = "driver/image"
        static let GetComplaints = "complaint/sync"
        static let CreateComplaint = "complaint/add"
        static let GetPayments = "payment/methods"
        static let PayTrip = "trip/pay"
        static let PayTripByApplePay = "trip/pay/device"
        static let MPGSSuccessToServer = "mpgs/3ds"
        static let MPGSCreateSession = "mpgs/session"
        static let DeletePaymentMethod = "payment/delete"
        static let GetInitialFareForPromo = "tariff/promo/"
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
    
    struct GetEstimateParam {
        static let PickLatitude = "pickupLat"
        static let PickLongitude = "pickupLon"
        static let DropLatitude = "dropLat"
        static let DropLongitude = "dropLon"
        static let PickTime = "pickupTime"
        static let PromoCode = "promoCode"
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
    
    struct EditAccountInfoParam {
        static let Name = "Name"
        static let Email = "Email"
        static let dob = "Dob"
        static let gender = "Gender"
        static let isEmailVerified = "IsEmailVerified"
        static let OldPassword = "Password"
        static let NewPassword = "NewPassword"
        static let DeviceToken = "DeviceToken"
    }
    
    struct UpdateBookmarkParam {
        static let LocationID = "LocationID"
        static let Latitude = "Lat"
        static let Longitude = "Lon"
    }
    
    struct SyncParam {
        static let BookingList = "synctime"
        static let VehicleTariff = "syncTime"
        static let CancelReason = "syncTime"
        static let RatingReason = "syncTime"
        static let Complaints = "syncTime"
        static let QUERY_PARAM_VEHICLE_TYPES = "vehicleTypes"
        static let QUERY_PARAM_INCLUDE_PATH = "includePath"
        static let VEHICLE_TYPES_ALL = "1,11,30,50,60,70"
    }
    
    
}
