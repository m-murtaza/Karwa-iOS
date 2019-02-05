//
//  KTVehicleTypeManage.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreLocation

//import SwiftyJSON

let INIT_TARIFF_SYNC_TIME = "InitTariffSyncTime"

class KTVehicleTypeManager: KTBaseFareEstimateManager {
    
    func tariffAvalible() -> Bool {
        guard let vTypes = VehicleTypes(), vTypes.count > 0 else {
            print("Tariff Not Available")
            return false
        }
        return true
    }
    
    func fetchInitialTariffLocal() {
        if !tariffAvalible(){
            //Tariff not available
            do {
                
                if let file = Bundle.main.url(forResource: "InitTariff", withExtension: "JSON") {
                    let data = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [String: Any] {
                        // json is a dictionary
                        self.saveInitTariff(response: object[Constants.ResponseAPIKey.Data] as! [Any])
                    }
                }
            }
            catch {
                print("error.localizedDescription")
            }
        }
        
    }
    
    func fetchBasicTariffFromServer(completion completionBlock: @escaping KTDALCompletionBlock) {
        let param : [String: Any] = [Constants.SyncParam.VehicleTariff: syncTime(forKey: INIT_TARIFF_SYNC_TIME)]
        
        self.get(url: Constants.APIURL.initTariff, param: param, completion: completionBlock) { (response, cBlock) in
            
            self.saveInitTariff(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    func saveInitTariff(response : [Any]){
        for r in response {
            
            self.saveSingleVehicleTariff(tariff: r as! [AnyHashable: Any])
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
    }
    
    func saveSingleVehicleTariff(tariff : [AnyHashable: Any]) {
        
        let vType : KTVehicleType = KTVehicleType.obj(withValue: tariff["VehicleType"]!, forAttrib: "typeId", inContext: NSManagedObjectContext.mr_default() ) as! KTVehicleType
        
        vType.typeBaseFare = tariff["Fare"] as? String
        vType.typeName = typeName(forId: vType.typeId)
        vType.typeSortOrder = typeSortOrder(forId: vType.typeId)
        
        
        for keyvalue in vType.toKeyValueBody! {
            (keyvalue as! KTKeyValue).mr_deleteEntity()
        }
        vType.toKeyValueBody = NSOrderedSet()
        saveKeyValueBody(keyValue: tariff["OrderedBody"] as! [[AnyHashable : Any]], tariff: vType as KTBaseTrariff)
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
    
    private func addTaxiType(localContext: NSManagedObjectContext) {
        
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeBaseFare = "10"
        vTypeTaxi.typeName = "Karwa Taxi"
        vTypeTaxi.typeId = Int16(VehicleType.KTCityTaxi.rawValue)
        vTypeTaxi.typeSortOrder = 1
        
    }
    private func addTaxiSevenSeaterType(localContext: NSManagedObjectContext) {
        
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeBaseFare = "10"
        vTypeTaxi.typeName = "Family car (7 Seater)"
        vTypeTaxi.typeId = Int16(VehicleType.KTCityTaxi7Seater.rawValue)
        vTypeTaxi.typeSortOrder = 2
        
    }
    private func addStandardLmioType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTStandardLimo.rawValue)
        vTypeTaxi.typeName = "Standard Limousine"
        vTypeTaxi.typeBaseFare = "40"
        vTypeTaxi.typeSortOrder = 3
    }
    private func addBusinessLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTBusinessLimo.rawValue)
        vTypeTaxi.typeName = "Business Limousine"
        vTypeTaxi.typeBaseFare = "50"
        vTypeTaxi.typeSortOrder = 4
    }
    private func addLuxuryLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTLuxuryLimo.rawValue)
        vTypeTaxi.typeName = "Luxury Limousine"
        vTypeTaxi.typeBaseFare = "70"
        vTypeTaxi.typeSortOrder = 5
    }
    
    func VehicleTypes() -> [KTVehicleType]? {
        var vTypes : [KTVehicleType] = []
        
        vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
        return vTypes.sorted(by: { (this, that) -> Bool in
            this.typeSortOrder < that.typeSortOrder
        })
    }
    
    func vehicleType(typeId : Int16) -> KTVehicleType? {
        var vType : KTVehicleType
        let predicate : NSPredicate = NSPredicate(format: "typeId == %d",typeId)
        vType  = (KTVehicleType.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default()))!
    
        return vType
    }
    
    static func isTaxi(vType: VehicleType) -> Bool {
        
        switch vType {
        case .KTCompactLimo,.KTStandardLimo,.KTBusinessLimo,.KTLuxuryLimo:
            return false
        default:
            return true
        }
    }

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
            
            let responseData = response[Constants.ResponseAPIKey.Data] as! [Any]
            
            if(responseData.count > 0)
            {
                MagicalRecord.save({ (context) in
                    KTBaseTrariff.mr_truncateAll(in: context)
                    KTKeyValue.mr_truncateAll(in: context)
                }, completion: { (changed, error) in
                    if let _ = error
                    {
                        print("Error truncating BaseTariff: \(String(describing: error?.localizedDescription))")
                    }
                    else
                    {
                        print("------------------------------------------")
                        print("Truncate BaseTaruff successful: \(changed)")
                        print(KTBaseTrariff.mr_countOfEntities())
                        print("------------------------------------------")
                        
                        self.saveInitTariff(response: responseData)
                        self.resetSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
                    }
                })
            }

            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
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
