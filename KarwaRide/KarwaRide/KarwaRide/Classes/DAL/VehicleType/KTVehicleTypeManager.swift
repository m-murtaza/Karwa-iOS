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
        if !tariffAvalible() || freshSynced(){
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
    
    func freshSynced() -> Bool
    {
        let currBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let buildNo = Int(currBuild)!

        return (buildNo < Constants.APP_REQUIRE_VEHICLE_UPDATE_VERSION)
    }
    
    func fetchBasicTariffFromServer(completion completionBlock: @escaping KTDALCompletionBlock) {
        let param : [String: Any] = [Constants.SyncParam.VehicleTariff: syncTime(forKey: INIT_TARIFF_SYNC_TIME),
                                     Constants.SyncParam.QUERY_PARAM_VEHICLE_TYPES: Constants.SyncParam.VEHICLE_TYPES_ALL]
        
        self.get(url: Constants.APIURL.initTariff, param: param, completion: completionBlock) { (response, cBlock) in
            if let data = response[Constants.ResponseAPIKey.Data] as? [Any], data.count > 0 {
                self.saveInitTariff(response: response[Constants.ResponseAPIKey.Data] as! [Any])
                self.updateSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
            }
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
        vType.isPromoApplied = tariff["IsPromoApplied"] as? Bool ?? false
        
        for keyvalue in vType.toKeyValueBody! {
            (keyvalue as! KTKeyValue).mr_deleteEntity()
        }
        vType.toKeyValueBody = NSOrderedSet()
        saveKeyValueBody(keyValue: tariff["OrderedBody"] as! [[AnyHashable : Any]], tariff: vType as KTBaseTrariff)
    }
    
//    func saveSingleVehicleEstimates(estimate : [AnyHashable: Any]) {
//        
//        let e : KTFareEstimate = KTFareEstimate.mr_createEntity(in: NSManagedObjectContext.mr_default())!
//        e.estimateId = estimate[Constants.GetEstimateResponseAPIKey.EstimateId] as? String
//        e.vehicleType = estimate[Constants.GetEstimateResponseAPIKey.VehicleType] as! Int16
//        e.estimatedFare = estimate[Constants.GetEstimateResponseAPIKey.EstimatedFare] as? String
//        e.isPromoApplied = estimate[Constants.GetEstimateResponseAPIKey.IsPromoApplied] as? Bool ?? false
//        
//        saveKeyValueBody(keyValue: estimate["OrderedBody"] as! [[AnyHashable : Any]], tariff: e as KTBaseTrariff)
//    }
    
    func typeSortOrder(forId typeId: Int16) -> Int16 {
        var order: Int16 = 999
        switch typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            order = 1
            break
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            order = 2
            break
        case Int16(VehicleType.KTSpecialNeedTaxi.rawValue):
            order = 3
            break
        /*case Int16(VehicleType.KTCompactLimo.rawValue):
            order = 4
            break*/
        case Int16(VehicleType.KTStandardLimo.rawValue):
            order = 4
            break
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            order = 5
            break
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            order = 6
            break
        case Int16(VehicleType.KTIconicLimousine.rawValue):
            order = 7
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
        case Int16(VehicleType.KTSpecialNeedTaxi.rawValue):
            name = "Accessible Taxi"
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
        case Int16(VehicleType.KTIconicLimousine.rawValue):
            name = "Electric Limousine"
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
    private func addTaxiSpecialAssistanceType(localContext: NSManagedObjectContext) {
        
        let vTypeSpecialAssistance = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeSpecialAssistance.typeBaseFare = "10"
        vTypeSpecialAssistance.typeName = "Accessible Taxi"
        vTypeSpecialAssistance.typeId = Int16(VehicleType.KTSpecialNeedTaxi.rawValue)
        vTypeSpecialAssistance.typeSortOrder = 3
        
    }
    private func addStandardLmioType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTStandardLimo.rawValue)
        vTypeTaxi.typeName = "Standard Limousine"
        vTypeTaxi.typeBaseFare = "40"
        vTypeTaxi.typeSortOrder = 4
    }
    private func addBusinessLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTBusinessLimo.rawValue)
        vTypeTaxi.typeName = "Business Limousine"
        vTypeTaxi.typeBaseFare = "50"
        vTypeTaxi.typeSortOrder = 5
    }
    private func addLuxuryLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTLuxuryLimo.rawValue)
        vTypeTaxi.typeName = "Luxury Limousine"
        vTypeTaxi.typeBaseFare = "70"
        vTypeTaxi.typeSortOrder = 6
    }
    
    func VehicleTypes() -> [KTVehicleType]? {
        var vTypes : [KTVehicleType] = []
        
        vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
        vTypes = vTypes.sorted(by: { (this, that) -> Bool in
            this.typeSortOrder < that.typeSortOrder
        })

        return vTypes
    }
    
    func vehicleType(typeId : Int16) -> KTVehicleType? {
        var vType : KTVehicleType
        let predicate : NSPredicate = NSPredicate(format: "typeId == %d",typeId)
        vType  = (KTVehicleType.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default()) ?? KTVehicleType())
    
        return vType
    }
    
    static func isTaxi(vType: VehicleType) -> Bool {
        
        switch vType {
        case .KTCompactLimo,.KTStandardLimo,.KTBusinessLimo,.KTLuxuryLimo, .KTXpressTaxi, .KTIconicLimousine:
            return false
        default:
            return true
        }
    }
  
  func fetchETA(pickup: CLLocationCoordinate2D, completion: @escaping KTDALCompletionBlock) {
    let param : [String : Any] = [Constants.AddressPickParams.Lat : pickup.latitude,
                                  Constants.AddressPickParams.Lon : pickup.longitude]
    
    self.get(url: Constants.APIURL.GetETA, param: param, completion: completion) { (response, cBlock) in
      let etas = response[Constants.ResponseAPIKey.Data] as! [[AnyHashable: Any]]
      func fetchEtaForVehicleType(vType: Int16) -> String {
        for eta in etas {
          guard let type = eta["VehicleType"] as? Int, vType == type  else { continue }
          guard let etaText = eta["EtaText"] as? String else { continue }
          return etaText
        }
        return ""
      }
      let vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
      for vehicle in vTypes {
        vehicle.etaText = fetchEtaForVehicleType(vType: vehicle.typeId)
      }
      NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
      cBlock(Constants.APIResponseStatus.SUCCESS, response)
    }
  }

    func fetchEstimate(pickup : CLLocationCoordinate2D, dropoff : CLLocationCoordinate2D, time: TimeInterval, complition complitionBlock:@escaping KTDALCompletionBlock ) {
        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                      Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                      Constants.GetEstimateParam.DropLatitude : dropoff.latitude,
                                      Constants.GetEstimateParam.DropLongitude : dropoff.longitude,
                                      Constants.GetEstimateParam.PickTime : time,
                                      Constants.SyncParam.QUERY_PARAM_INCLUDE_PATH : "true",
                                      Constants.SyncParam.QUERY_PARAM_VEHICLE_TYPES : Constants.SyncParam.VEHICLE_TYPES_ALL]
        
        self.get(url: Constants.APIURL.GetEstimate, param: param, completion: complitionBlock) { (response, cBlock) in
            

//            self.saveEstimates(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            
            let estimatesBean = response[Constants.BookingResponseAPIKey.Estimates] as! [Any]
            self.saveEstimates(response: estimatesBean)

            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }

    func fetchEstimateForPromo(pickup : CLLocationCoordinate2D, dropoff : CLLocationCoordinate2D, time: TimeInterval, promo: String, complition complitionBlock:@escaping KTDALCompletionBlock ) {
        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                      Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                      Constants.GetEstimateParam.DropLatitude : dropoff.latitude,
                                      Constants.GetEstimateParam.DropLongitude : dropoff.longitude,
                                      Constants.GetEstimateParam.PickTime : time,
                                      Constants.GetEstimateParam.PromoCode : promo,
                                      Constants.SyncParam.QUERY_PARAM_INCLUDE_PATH : "true",
                                      Constants.SyncParam.QUERY_PARAM_VEHICLE_TYPES : Constants.SyncParam.VEHICLE_TYPES_ALL]
        
        self.get(url: Constants.APIURL.GetPromoEstimate, param: param, completion: complitionBlock) { (response, cBlock) in
            
//            let encodedPath = response[Constants.BookingResponseAPIKey.EncodedPath] as! String
            let estimatesBean = response[Constants.BookingResponseAPIKey.Estimates] as! [Any]
            self.saveEstimates(response: estimatesBean)

//            self.saveEstimates(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    func fetchEstimateForPromo(pickup : CLLocationCoordinate2D, time: TimeInterval, promo: String, complition complitionBlock:@escaping KTDALCompletionBlock ) {

        let param : [String : Any] = [Constants.GetEstimateParam.PickLatitude : pickup.latitude,
                                      Constants.GetEstimateParam.PickLongitude : pickup.longitude,
                                      Constants.GetEstimateParam.PickTime : time,
                                      Constants.SyncParam.QUERY_PARAM_VEHICLE_TYPES : Constants.SyncParam.VEHICLE_TYPES_ALL,
                                      Constants.SyncParam.QUERY_PARAM_INCLUDE_PATH : "true",
                                      Constants.GetEstimateParam.PromoCode : promo]
        
        self.get(url: Constants.APIURL.GetInitialFareForPromo, param: param, completion: complitionBlock)
        {(response, cBlock) in
            
            let responseData = response[Constants.ResponseAPIKey.Data] as! [Any]
            
            if(responseData.count > 0)
            {   
                 MagicalRecord.save({ (context) in
                    KTBaseTrariff.mr_truncateAll(in: context)
                    KTKeyValue.mr_truncateAll(in: context)
                    KTDALManager().resetSyncTime(forKey: BOOKING_SYNC_TIME)
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
        e.isPromoApplied = estimate[Constants.GetEstimateResponseAPIKey.IsPromoApplied] as? Bool ?? false
        
        saveKeyValueBody(keyValue: estimate["OrderedBody"] as! [[AnyHashable : Any]], tariff: e as KTBaseTrariff)
    }
    
    
    func estimates() -> [KTFareEstimate] {
        
        let predicate : NSPredicate = NSPredicate(format: "fareestimateToBooking == nil")
        return KTFareEstimate.mr_findAll(with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTFareEstimate]
    }
    
}
