//
//  KTBookingManager+Estimate.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

extension KTBookingManager {
    
    func fetchEstimate(pickup : CLLocationCoordinate2D, dropoff : CLLocationCoordinate2D, time: TimeInterval, complition complitionBlock:@escaping KTDALCompletionBlock ) {
        
        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                    Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                    Constants.GetEstimateParam.DropLatitude : dropoff.latitude,
                                    Constants.GetEstimateParam.DropLongitude : dropoff.longitude,
                                    Constants.GetEstimateParam.PickTime : time]
        
        self.get(url: Constants.APIURL.GetEstimate, param: param, completion: complitionBlock) { (response, cBlock) in
            
            self.saveEstimates(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    func fetchEstimateForPromo(pickup : CLLocationCoordinate2D, dropoff : CLLocationCoordinate2D, time: TimeInterval, promo: String, complition complitionBlock:@escaping KTDALCompletionBlock ) {
        
        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                      Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                      Constants.GetEstimateParam.DropLatitude : dropoff.latitude,
                                      Constants.GetEstimateParam.DropLongitude : dropoff.longitude,
                                      Constants.GetEstimateParam.PickTime : time,
                                      Constants.GetEstimateParam.PromoCode : promo]
        
        self.get(url: Constants.APIURL.GetPromoEstimate, param: param, completion: complitionBlock) { (response, cBlock) in
            
            self.saveEstimates(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    func fetchEstimateForPromo(pickup : CLLocationCoordinate2D, time: TimeInterval, promo: String, complition complitionBlock:@escaping KTDALCompletionBlock ) {

        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                      Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                      Constants.GetEstimateParam.PickTime : time,
                                      Constants.GetEstimateParam.PromoCode : promo]
        
        self.get(url: Constants.APIURL.GetInitialFareForPromo, param: param, completion: complitionBlock)
        {(response, cBlock) in
            
            let responseArr = response[Constants.ResponseAPIKey.Data] as! [Any]
            
            for r in responseArr
            {
                let tariff = r as! [AnyHashable: Any]

                let vType = tariff["VehicleType"] as? Int
                let fare = tariff["Fare"] as? String
                let keyValue = tariff["OrderedBody"] as! [[AnyHashable : Any]]

//                let vType : KTVehicleType = KTVehicleType.obj(withValue: tariff["VehicleType"]!, forAttrib: "typeId", inContext: NSManagedObjectContext.mr_default() ) as! KTVehicleType
//
//                vType.typeBaseFare = tariff["Fare"] as? String
//                vType.typeName = self.typeName(forId: vType.typeId)
//                vType.typeSortOrder = self.typeSortOrder(forId: vType.typeId)
//
//                for keyvalue in vType.toKeyValueBody!
//                {
//                    (keyvalue as! KTKeyValue).mr_deleteEntity()
//                }
//                vType.toKeyValueBody = NSOrderedSet()
//                self.saveKeyValueBody(keyValue: tariff["OrderedBody"] as! [[AnyHashable : Any]], tariff: vType as KTBaseTrariff)
            }
        }
    }
    
    func typeSortOrder(forId typeId: Int16) -> Int16 {
        var order: Int16 = 999
        switch typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            order = 1
            break
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            order = 2
            break
        case Int16(VehicleType.KTCompactLimo.rawValue):
            order = 3
            break
        case Int16(VehicleType.KTStandardLimo.rawValue):
            order = 4
            break
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            order = 5
            break
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            order = 6
            break
        default:
            order = 999
            break
        }
        return order
    }
    func typeName(forId typeId: Int16) -> String {
        var name: String = ""
        switch typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            name = "Karwa Taxi"
            break
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            name = "Family Taxi (7 Seater)"
            break
        case Int16(VehicleType.KTCompactLimo.rawValue):
            name = "Compact Limousine"
            break
        case Int16(VehicleType.KTStandardLimo.rawValue):
            name = "Standard Limousine"
            break
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            name = "Business Limousine"
            break
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            name = "Luxury Limousine"
            break
        default:
            name = "Karwa"
            break
        }
        return name
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    func saveEstimates(response : [Any]){
        let predicate : NSPredicate = NSPredicate(format: "fareestimateToBooking == nil")
        KTFareEstimate.mr_deleteAll(matching: predicate, in: NSManagedObjectContext.mr_default() )
        for r in response {
            
            self.saveSingleVehicleEstimates(estimate: r as! [AnyHashable: Any])
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
    }
    
    func saveSingleVehicleEstimates(estimate : [AnyHashable: Any]) {
        
        let e : KTFareEstimate = KTFareEstimate.mr_createEntity(in: NSManagedObjectContext.mr_default())!
        e.estimateId = estimate[Constants.GetEstimateResponseAPIKey.EstimateId] as? String
        e.vehicleType = estimate[Constants.GetEstimateResponseAPIKey.VehicleType] as! Int16
        e.estimatedFare = estimate[Constants.GetEstimateResponseAPIKey.EstimatedFare] as? String
        
        saveKeyValueBody(keyValue: estimate["OrderedBody"] as! [[AnyHashable : Any]], tariff: e as KTBaseTrariff)
    }
    
    
    func estimates() -> [KTFareEstimate] {
        
        let predicate : NSPredicate = NSPredicate(format: "fareestimateToBooking == nil")
        return KTFareEstimate.mr_findAll(with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTFareEstimate]
    }
}
