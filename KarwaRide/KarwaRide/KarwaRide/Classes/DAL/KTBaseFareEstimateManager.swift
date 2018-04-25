//
//  KTBaseFareEstimateManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTBaseFareEstimateManager: KTDALManager {
    
//    func saveKeyValueBody(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
//        let keys =  Array(kv.keys)
//        for key in keys {
//
//            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
//            keyValue.key = key as? String
//            keyValue.value = kv[key] as? String
//
//            /*let mutableItems = estimate?.toKeyValueHeader?.mutableCopy() as! NSMutableOrderedSet
//            mutableItems.add(kv)
//            estimate?.toKeyValueHeader = mutableItems.copy() as? NSOrderedSet*/
//
//            tariff.toKeyValueBody = tariff.toKeyValueBody!.adding(keyValue)
//        }
//    }
    
    func saveKeyValueBody(keyValue kv: [[AnyHashable : Any]],  tariff: KTBaseTrariff) {
        
        //kv.sorted(by: { $0.fileID > $1.fileID })
        
        let sortedArray = kv.sorted {($0["Order"] as! Int) < ($1["Order"] as! Int)}
        
        for obj in sortedArray  {
            print(obj["Key"] as? String)
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = obj["Key"] as? String
            keyValue.value = obj["Value"] as? String
            
            tariff.toKeyValueBody = tariff.toKeyValueBody!.adding(keyValue)
        }
    }
    
    func saveKeyValueHeader(keyValue kv: [[AnyHashable:Any]],  tariff: KTBaseTrariff) {
        
        let sortedArray = kv.sorted {($0["Order"] as! Int) < ($1["Order"] as! Int)}
        
        for obj in sortedArray  {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = obj["Key"] as? String
            keyValue.value = obj["Value"] as? String
            
            tariff.toKeyValueHeader = tariff.toKeyValueHeader!.adding(keyValue)
        }
        
        /*let keys =  Array(kv.keys)
        for key in keys {
            
            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
            keyValue.key = key as? String
            keyValue.value = kv[key] as? String
            tariff.toKeyValueHeader = tariff.toKeyValueHeader!.adding(keyValue)
        }*/
    }
    
    
//    func saveKeyValueHeader(keyValue kv: [AnyHashable:Any],  tariff: KTBaseTrariff) {
//        let keys =  Array(kv.keys)
//        for key in keys {
//            
//            let keyValue : KTKeyValue = KTKeyValue.mr_createEntity()!
//            keyValue.key = key as? String
//            keyValue.value = kv[key] as? String
//            tariff.toKeyValueHeader = tariff.toKeyValueHeader!.adding(keyValue)
//        }
//    }
    
    func keyValue(forKey key: String, value:String) -> KTKeyValue {
        let kv : KTKeyValue = KTKeyValue.mr_createEntity()!
        kv.key = key
        kv.value = value
        return kv
    }
}
