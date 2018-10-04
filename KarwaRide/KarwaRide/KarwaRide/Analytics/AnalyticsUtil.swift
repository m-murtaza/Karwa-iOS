//
//  File.swift
//  KarwaRide
//
//  Created by Sam Ash on 9/19/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsUtil
{
    static func trackBehavior(event name: String)
    {
        Analytics.logEvent("karwa_user_behaviour", parameters: [
            "item_name": name as NSObject
            ])
    }
}
