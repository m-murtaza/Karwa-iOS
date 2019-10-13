//
//  SharedPrefUtil.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class SharedPrefUtil
{
    static let IS_COACHMARKS_SHOWN = "IS_COACHMARKS_SHOWN"
    static let IS_APP_STORE_RATING_DONE = "IS_APP_STORE_RATING_DONE"
    static let IS_SHARE_TRIP_TOOL_TIP_SHOWN = "IS_SHARE_TRIP_TOOL_TIP_SHOWN"
    static let IS_RATING_REASONS_RESET_FORCEFULLY = "IS_RATING_REASONS_RESET_FORCEFULLY"

    static let IS_SCAN_PAY_COACHMARK_SHOWN = "IS_SCAN_PAY_COACHMARK_SHOWN"
    static let IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT = "IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT"
    static let SYNC_TIME_COMPLAINTS = "SYNC_TIME_COMPLAINTS"

    static func setSharedPref(_ key:String, _ value: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    public static func getSharePref(_ key:String) -> String
    {
        let defaults = UserDefaults.standard
        if let stringOne = defaults.string(forKey: key)
        {
            return stringOne
        }
        else
        {
            return ""
        }
    }
    
    static func setScanNPayCoachmarkShown()
    {
        let defaults = UserDefaults.standard
        defaults.set("true", forKey: IS_SCAN_PAY_COACHMARK_SHOWN)
    }
    
    public static func isScanNPayCoachmarkShown() -> Bool
    {
        let isShown = SharedPrefUtil.getSharePref(IS_SCAN_PAY_COACHMARK_SHOWN)
        
        if(isShown.isEmpty || isShown.count == 0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    static func setScanNPayCoachmarkShownInDetails()
    {
        let defaults = UserDefaults.standard
        defaults.set("true", forKey: IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT)
    }
    
    public static func isScanNPayCoachmarkShownInDetails() -> Bool
    {
        let isShown = SharedPrefUtil.getSharePref(IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT)
        
        if(isShown.isEmpty || isShown.count == 0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    public static func isBookingCoachmarkOneShown() -> Bool
    {
        let isCoachmarksShown = SharedPrefUtil.getSharePref(SharedPrefUtil.IS_COACHMARKS_SHOWN)
        
        if(isCoachmarksShown.isEmpty || isCoachmarksShown.count == 0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    public static func resetRideIfRequired()
    {
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let buildNo = Int(currBuild)!

        if(buildNo < Constants.APP_REQUIRE_VEHICLE_UPDATE_VERSION)
        {
            KTDALManager().resetSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
        }
    }
}
