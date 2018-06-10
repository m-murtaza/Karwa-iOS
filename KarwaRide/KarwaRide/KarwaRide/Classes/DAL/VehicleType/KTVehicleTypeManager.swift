//
//  KTVehicleTypeManage.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord
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
            name = "Karwa Taxi Seven Seater"
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
        vTypeTaxi.typeName = "Karwa Taxi Seven Seater"
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
    
}
