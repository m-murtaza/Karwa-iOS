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
    static let IS_APP_STORE_RATING_DONE = "IS_APP_STORE_RATING_DONE"
    static let IS_SHARE_TRIP_TOOL_TIP_SHOWN = "IS_SHARE_TRIP_TOOL_TIP_SHOWN"
    static let IS_RATING_REASONS_RESET_FORCEFULLY = "IS_RATING_REASONS_RESET_FORCEFULLY_V_2"

    static let IS_SCAN_PAY_COACHMARK_SHOWN = "IS_SCAN_PAY_COACHMARK_SHOWN"
    static let IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT = "IS_SCAN_PAY_COACHMARK_SHOWN_ON_PAYMENT"
    static let SYNC_TIME_COMPLAINTS = "SYNC_TIME_COMPLAINTS"

    static let LANGUAGE_SET = "LANGUAGE_SET"
    static let DELTA_TO_TRUE_TIME = "DELTA_TO_REAL_TIME"
    static let ENVIRONMENT = "ENVIRONMENT"
    static let PROMOTION_TOOLTIP_COUNT = "PROMOTION_TOOLTIP_COUNT"
    
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
    
    public static func setDeltaToRealTime(deltaTimeInMilliseconds delta : Double)
    {
        let defaults = UserDefaults.standard
        defaults.setValue("\(delta)", forKey: DELTA_TO_TRUE_TIME)
    }
    
    public static func getDeltaToRealTime() -> Double
    {
        return Double(getSharePref(DELTA_TO_TRUE_TIME)) ?? 0
    }
    
    public static func setLanguageChanged(setLanguage language : String)
    {
        let defaults = UserDefaults.standard
        defaults.set(language, forKey: LANGUAGE_SET)
    }
    
    public static func isLanguageChanged() -> Bool
    {
        return Device.language() != SharedPrefUtil.getSharePref(LANGUAGE_SET)
    }
    
    public static func resetRideIfRequired()
    {
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let buildNo = Int(currBuild)!

        if(buildNo < Constants.APP_REQUIRE_VEHICLE_UPDATE_VERSION || SharedPrefUtil.isLanguageChanged())
        {
            KTDALManager().resetSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
        }
    }
}
