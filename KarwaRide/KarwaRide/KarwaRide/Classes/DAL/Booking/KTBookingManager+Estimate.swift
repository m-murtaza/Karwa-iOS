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
