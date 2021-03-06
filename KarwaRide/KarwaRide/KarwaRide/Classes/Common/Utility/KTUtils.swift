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
    
    static func getEtaBackgroundNameByVT(vehicleType: Int16) -> String
    {
        var backgroundName = "EtaToCustomerBack1"

        switch vehicleType
        {
        case VehicleType.KTCityTaxi.rawValue:
            backgroundName = "EtaToCustomerBack1"
        case VehicleType.KTCityTaxi7Seater.rawValue:
            backgroundName = "EtaToCustomerBack5"
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            backgroundName = "EtaToCustomerBack6"
        case VehicleType.KTStandardLimo.rawValue:
            backgroundName = "EtaToCustomerBack2"
        case VehicleType.KTBusinessLimo.rawValue:
            backgroundName = "EtaToCustomerBack3"
        case VehicleType.KTLuxuryLimo.rawValue:
            backgroundName = "EtaToCustomerBack4"
        default:
            backgroundName = "EtaToCustomerBack1"
        }
        
        return backgroundName
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
            backgroundName = "EtaToCustomerBack6"
        case 3:
            backgroundName = "EtaToCustomerBack2"
        case 4:
            backgroundName = "EtaToCustomerBack3"
        case 5:
            backgroundName = "EtaToCustomerBack4"
        default:
            backgroundName = "EtaToCustomerBack1"
        }

        return backgroundName
    }
    
    static func reorderVehicleTypes(vehicleTypes: [KTVehicleType]) -> [KTVehicleType]? {
        if(vehicleTypes.count == 6)
        {
            var sortedVehicleTypes = vehicleTypes
            var temp = sortedVehicleTypes[2]
            sortedVehicleTypes[2] = sortedVehicleTypes[4]
            sortedVehicleTypes[4] = temp
        }

        return vehicleTypes
    }
    
    static func getETAString(etaInSeconds: Int) -> String
    {
        var etaString = "1 min"
        if(etaInSeconds > 119)
        {
            etaString = String(etaInSeconds / 60) + " mins"
        }
        return etaString
    }
    
    static func isValidQRCode(_ code: String) -> PayTripBeanForServer?
    {
        let qrCodeData = code.replacingOccurrences(of: "https://", with: "", options: .literal, range: nil)
            .replacingOccurrences(of: "http://", with: "", options: .literal, range: nil)
            .replacingOccurrences(of: "app.karwatechnologies.com", with: "", options: .literal, range: nil)
            .replacingOccurrences(of: "/download/", with: "", options: .literal, range: nil)

        let piecesOfPayBean = qrCodeData.split(separator: ",")
        if(piecesOfPayBean.count == 4)
        {
            return PayTripBeanForServer("", "", String(piecesOfPayBean[1]), String(piecesOfPayBean[2]), Int(piecesOfPayBean[3])!, "", "", "", String(piecesOfPayBean[0]))
        }
        else
        {
            return nil
        }
    }
    
    static func isValidTrackTripCode(_ code: String) -> String?
    {
        let trackCode = code.replacingOccurrences(of: "https://", with: "", options: .literal, range: nil).replacingOccurrences(of: "http://", with: "", options: .literal, range: nil).replacingOccurrences(of: "www.app.karwatechnologies.com", with: "", options: .literal, range: nil).replacingOccurrences(of: "/track/", with: "", options: .literal, range: nil)
        
        if(trackCode.count > 3)
        {
            return trackCode
        }
        else
        {
            return nil
        }
    }
}
