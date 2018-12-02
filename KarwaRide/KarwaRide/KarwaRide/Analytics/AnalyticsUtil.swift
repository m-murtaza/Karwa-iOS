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
    static let SHARE_RIDE = "share_ride"
    static let REMOVE_PAYMENT_INFO = "remove_payment_info"

    static func trackBehavior(event name: String)
    {
        #if DEBUG || ADHOC
        print("Skipping Analytics because of debug build")
        #else
        Analytics.logEvent("karwa_user_behaviour", parameters: [
            "item_name": name as String
            ])
        #endif
    }
    
    static func trackAddPaymentMethod(_ cardType: String)
    {
        #if DEBUG || ADHOC
        print("Skipping Analytics because of debug build")
        #else
        Analytics.logEvent(FirebaseAnalytics.AnalyticsEventAddPaymentInfo,
                           parameters:
            [
                FirebaseAnalytics.AnalyticsParameterValue: cardType as String
            ])
        #endif
    }
    
    static func trackRemovePaymentMethod(_ cardType: String)
    {
        #if DEBUG || ADHOC
        print("Skipping Analytics because of debug build")
        #else
        Analytics.logEvent(REMOVE_PAYMENT_INFO,
                           parameters:
            [
                FirebaseAnalytics.AnalyticsParameterValue: cardType as String
            ])

        #endif
    }

    static func trackCardPayment(_ amount: String)
    {
        #if DEBUG || ADHOC
        print("Skipping Analytics because of debug build")
        #else
        Analytics.logEvent(FirebaseAnalytics.AnalyticsEventEcommercePurchase,
                           parameters:
            [
                FirebaseAnalytics.AnalyticsParameterCurrency : "QAR" as String,
                FirebaseAnalytics.AnalyticsParameterValue : Double(amount) ?? 0
            ])
        #endif
    }
    
    static func trackShareRide()
    {
        #if DEBUG || ADHOC
        print("Skipping Analytics because of debug build")
        #else
        Analytics.logEvent(SHARE_RIDE, parameters:[:])
        #endif
    }
}
