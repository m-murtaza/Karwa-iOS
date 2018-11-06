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
    static let REMOVE_PAYMENT_INFO = "remove_payment_info"

    static func trackBehavior(event name: String)
    {
        #if RELEASE
            Analytics.logEvent("karwa_user_behaviour", parameters: [
                "item_name": name as String
                ])
        #else
            print("Skipping Analytics because of debug build")
        #endif
    }
    
    static func trackAddPaymentMethod(_ cardType: String)
    {
        #if RELEASE
        Analytics.logEvent(FirebaseAnalytics.AnalyticsEventAddPaymentInfo,
            parameters:
            [
                FirebaseAnalytics.AnalyticsParameterItemBrand: cardType as String
            ])
        #else
            print("Skipping Analytics because of debug build")
        #endif
    }
    
    static func trackRemovePaymentMethod(_ cardType: String)
    {
        #if RELEASE
        Analytics.logEvent(REMOVE_PAYMENT_INFO,
            parameters:
            [
                FirebaseAnalytics.AnalyticsParameterItemBrand: cardType as String
            ])
        #else
        print("Skipping Analytics because of debug build")
        #endif
    }
    
    static func trackCardPayment(_ amount: String)
    {
        #if RELEASE
        Analytics.logEvent(FirebaseAnalytics.AnalyticsEventEcommercePurchase,
            parameters:
            [
                FirebaseAnalytics.AnalyticsParameterCurrency : "QAR" as String,
                FirebaseAnalytics.AnalyticsParameterPrice : Double(amount) as Double
            ])
        #else
        print("Skipping Analytics because of debug build")
        #endif
    }
}
