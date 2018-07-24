//
//  KTUtils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
class KTUtils
{
    static func isObjectNotNil(object:AnyObject!) -> Bool
    {
        /*if let _:AnyObject = object
        {
            return true
        }
        
        return false*/
        guard let _ = object else {
            return false
        }
        return true
    }
    
    static func getLocationParams(vehicles: [VehicleTrack]) -> String
    {
        var param = "";
        for i in 0..<vehicles.count
        {
            let lat = String(format: "%f", vehicles[i].position.latitude)
            let lon = String(format: "%f", vehicles[i].position.longitude)
            let rideLocation = lat + "," + lon
            if(i==vehicles.count-1)
            {
                param.append(rideLocation)
            }
            else
            {
                param.append(rideLocation+"|")
            }
        }

        return param;
    }
    
    static func getEtaBackgroundName(index: Int) -> String
    {
        var backgroundName = "EtaToCustomerBack1"

        switch index
        {
        case 0:
            backgroundName = "EtaToCustomerBack1"
        case 1:
            backgroundName = "EtaToCustomerBack5"
        case 2:
            backgroundName = "EtaToCustomerBack2"
        case 3:
            backgroundName = "EtaToCustomerBack3"
        case 4:
            backgroundName = "EtaToCustomerBack4"
        default:
            backgroundName = "EtaToCustomerBack1"
        }

        return backgroundName
    }
    
    static func getETAString(etaInSeconds: Int) -> String
    {
        var etaString = "1 min to reach"
        if(etaInSeconds < 60)
        {
            etaString = "\(etaInSeconds) secs to reach"
        }
        else if(etaInSeconds > 119)
        {
            etaString = String(etaInSeconds / 60) + " mins to reach"
        }
        return etaString
    }
}
