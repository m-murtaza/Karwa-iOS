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
    static let IS_COACHMARKS_SHOWN = "IS_COACHMARKS_SHOWN";
    static let IS_APP_STORE_RATING_DONE = "IS_APP_STORE_RATING_DONE";
    
    static let SYNC_TIME_COMPLAINTS = "SYNC_TIME_COMPLAINTS";

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
}
