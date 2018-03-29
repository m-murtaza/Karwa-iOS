//
//  KTVehicleTypeManage.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

let INIT_TARIFF_SYNC_TIME = "InitTariffSyncTime"

class KTVehicleTypeManager: KTDALManager {

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
        
        for keyvalue in vType.tariffToKeyValue! {
            (keyvalue as! KTKeyValue).mr_deleteEntity()
        }
        
        saveKeyValue(keyValue: tariff["Body"] as! [AnyHashable : Any], tariff: vType as KTBaseTrariff)
    }
    
    func saveKeyValue(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
        let keys =  Array(kv.keys)
        for key in keys {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = key as? String
            keyValue.value = kv[key] as? String
            tariff.tariffToKeyValue?.adding(keyValue)
        }
        
    }
    
    
    
    func typeSortOrder(forId typeId: Int16) -> Int16 {
        var order: Int16 = 999
        switch typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            order = 1
            break
        case Int16(VehicleType.KTCompactLimo.rawValue):
            order = 2
            break
        case Int16(VehicleType.KTStandardLimo.rawValue):
            order = 3
            break
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            order = 4
            break
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            order = 5
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
    
    
    func syncDefaultVechicletypes() {
        
        if (UserDefaults.standard.value(forKey: "VehicleTypeSaved") == nil)
        {
            MagicalRecord.save( { (_ localContext: NSManagedObjectContext) in
                _ = KTVehicleType.mr_truncateAll(in: localContext)
            
                self.addTaxiType(localContext: localContext)
                self.addStandardLmioType(localContext: localContext)
                self.addBusinessLimoType(localContext: localContext)
                self.addLuxuryLimoType(localContext: localContext)
            })
        
            UserDefaults.standard.set(true, forKey: "VehicleTypeSaved")
        }
    }
    
    /*
     MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
     _ = KTUser.mr_truncateAll(in: localContext)
     let user : KTUser = KTUser.mr_createEntity(in: localContext)! //KTUser.mr_createEntity()!
     user.customerType = response[Constants.LoginResponseAPIKey.CustomerType] as! Int32
     user.name = response[Constants.LoginResponseAPIKey.Name] as? String
     user.phone = response[Constants.LoginResponseAPIKey.Phone] as? String
     user.email = response[Constants.LoginResponseAPIKey.Email] as? String
     user.sessionId = response[Constants.LoginResponseAPIKey.SessionID] as? String
     }
     */
    
    private func addTaxiType(localContext: NSManagedObjectContext) {
        //MagicalRecord.save( { (_ localContext: NSManagedObjectContext) in
        //    _ = KTVehicleType.mr_truncateAll(in: localContext)
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeBaseFare = "10"
        vTypeTaxi.typeName = "Karwa Taxi"
        vTypeTaxi.typeId = Int16(VehicleType.KTCityTaxi.rawValue)
        vTypeTaxi.typeSortOrder = 1
        
        //})
    }
    private func addStandardLmioType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTStandardLimo.rawValue)
        vTypeTaxi.typeName = "Standard Limousine"
        vTypeTaxi.typeBaseFare = "40"
        vTypeTaxi.typeSortOrder = 2
    }
    private func addBusinessLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTBusinessLimo.rawValue)
        vTypeTaxi.typeName = "Business Limousine"
        vTypeTaxi.typeBaseFare = "50"
        vTypeTaxi.typeSortOrder = 3
    }
    private func addLuxuryLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTLuxuryLimo.rawValue)
        vTypeTaxi.typeName = "Luxury Limousine"
        vTypeTaxi.typeBaseFare = "70"
        vTypeTaxi.typeSortOrder = 4
    }
    
    func VehicleTypes() -> [KTVehicleType]? {
        var vTypes : [KTVehicleType] = []
        
        vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
        return vTypes.sorted(by: { (this, that) -> Bool in
            this.typeSortOrder < that.typeSortOrder
        })
    }
    /*
    case Unknown = -1
    case KTCityTaxi = 1
    case KTAiport7Seater = 3
    case KTAirportSpare = 5
    case KTSpecialNeedTaxi = 10
    case KTAiportTaxi = 11
    case KTCompactLimo = 20
    case KTStandardLimo = 30
    case KTBusinessLimo = 50
    case KTLuxuryLimo = 70*/
    
    static func isTaxi(vType: VehicleType) -> Bool {
        
        switch vType {
        case .KTCompactLimo,.KTStandardLimo,.KTBusinessLimo,.KTLuxuryLimo:
            return false
        default:
            return true
        }
    }
    
}
