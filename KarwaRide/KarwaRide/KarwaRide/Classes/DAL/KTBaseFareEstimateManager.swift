//
//  KTBaseFareEstimateManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTBaseFareEstimateManager: KTDALManager {
    
    func saveKeyValue(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
        let keys =  Array(kv.keys)
        for key in keys {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = key as? String
            keyValue.value = kv[key] as? String
            tariff.tariffToKeyValue = tariff.tariffToKeyValue?.adding(keyValue) as! NSSet
        }
    }
}
