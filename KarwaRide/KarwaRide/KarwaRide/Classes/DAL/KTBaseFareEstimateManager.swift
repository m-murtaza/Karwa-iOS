//
//  KTBaseFareEstimateManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTBaseFareEstimateManager: KTDALManager {
    
    func saveKeyValueBody(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
        let keys =  Array(kv.keys)
        for key in keys {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = key as? String
            keyValue.value = kv[key] as? String
            tariff.toKeyValueBody = tariff.toKeyValueBody?.adding(keyValue) as! NSSet
        }
    }
    
    func saveKeyValueHeader(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
        let keys =  Array(kv.keys)
        for key in keys {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = key as? String
            keyValue.value = kv[key] as? String
            tariff.toKeyValueHeader = tariff.toKeyValueHeader?.adding(keyValue) as! NSSet
        }
    }
    
    func keyValue(forKey key: String, value:String) -> KTKeyValue {
        let kv : KTKeyValue = KTKeyValue.mr_createEntity()!
        kv.key = key
        kv.value = value
        return kv
    }
}
