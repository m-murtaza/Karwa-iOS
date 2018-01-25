//
//  KTVehicleTypeManage.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord


class KTVehicleTypeManager: KTDALManager {

    func addDefaultVechicletypes() {
        
        if (UserDefaults.standard.value(forKey: "VehicleTypeSaved") == nil)
        {
            MagicalRecord.save( { (_ localContext: NSManagedObjectContext) in
                _ = KTVehicleType.mr_truncateAll(in: localContext)
            
                self.addTaxiType(localContext: localContext)
                self.addStandardLmioType(localContext: localContext)
                self.addBusinessLimoType(localContext: localContext)
                self.addLuxuryLimoType(localContext: localContext)
            }, completion: {(_ success: Bool, _ error: Error?) -> Void in
                print("Success")
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
        vTypeTaxi.typeBaseFare = 10
        vTypeTaxi.typeName = "Karwa Taxi"
        vTypeTaxi.typeId = Int16(VehicleType.KTCityTaxi.rawValue)
        vTypeTaxi.typeSortOrder = 1
        
        //})
    }
    private func addStandardLmioType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTStandardLimo.rawValue)
        vTypeTaxi.typeName = "Standard Limousine"
        vTypeTaxi.typeBaseFare = 40
        vTypeTaxi.typeSortOrder = 2
    }
    private func addBusinessLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTBusinessLimo.rawValue)
        vTypeTaxi.typeName = "Business Limousine"
        vTypeTaxi.typeBaseFare = 50
        vTypeTaxi.typeSortOrder = 3
    }
    private func addLuxuryLimoType(localContext: NSManagedObjectContext) {
        let vTypeTaxi = KTVehicleType.mr_createEntity(in: localContext)!
        vTypeTaxi.typeId = Int16(VehicleType.KTLuxuryLimo.rawValue)
        vTypeTaxi.typeName = "Luxury Limousine"
        vTypeTaxi.typeBaseFare = 70
        vTypeTaxi.typeSortOrder = 4
    }
    
    func VehicleTypes() -> [KTVehicleType]? {
        var vTypes : [KTVehicleType] = []
        
        vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
        return vTypes.sorted(by: { (this, that) -> Bool in
            this.typeSortOrder < that.typeSortOrder
        })
    }
    
}
