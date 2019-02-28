//
//  PayTripBeanForServer.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/28/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class PayTripBeanForServer
{
    var driverId: String
    var paymentMethodId: String
    var totalFare: String
    var tripId: String
    var tripType: Int
    var data: String
    var u: String
    var s: String
    var e: String
    
    init(_ driverId: String, _ paymentMethodId: String, _ totalFare: String, _ tripId: String, _ tripType: Int,  _ u: String,  _ s: String,  _ e: String, _ data: String)
    {
        self.driverId = driverId
        self.paymentMethodId = paymentMethodId
        self.totalFare = totalFare
        self.tripId = tripId
        self.tripType = tripType
        self.u = u
        self.s = s
        self.e = e
        self.data = data
    }
}
