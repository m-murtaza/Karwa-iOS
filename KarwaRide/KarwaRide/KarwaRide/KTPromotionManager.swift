//
//  KTPromotionManager.swift
//  KarwaRide
//
//  Created by Piecyfer on 19/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class KTPromotionManager: KTDALManager {
    
    func fetchPromotions(completion completionBlock: @escaping KTDALCompletionBlock) {
        self.get(url: Constants.APIURL.Promotions, param: nil, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
    }
    
    func fetchGeoPromotions(pickup: String?, dropoff: String?, completion completionBlock: @escaping KTDALCompletionBlock) {
        var param : [String: Any] = [:]
        if let pickup = pickup {
            param[Constants.PromotionParams.Pickup] = pickup
        }
        if let dropoff = dropoff {
            param[Constants.PromotionParams.Dropoff] = dropoff
        }
        
        let url = Constants.APIURL.Promotions + "/geo?" + param.queryString
        
        self.get(url: url, param: nil, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
    }
}
