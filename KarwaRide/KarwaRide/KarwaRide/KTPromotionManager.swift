//
//  KTPromotionManager.swift
//  KarwaRide
//
//  Created by Piecyfer on 19/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class KTPromotionManager: KTDALManager {
    
    func fetchPromotions(params: PromotionParams, completion completionBlock: @escaping KTDALCompletionBlock) {
        var param : [String: Any] = [:]
        if let pickupLat = params.pickupLat, let pickupLong = params.pickupLong {
            param[Constants.PromotionParams.PickupLat] = pickupLat
            param[Constants.PromotionParams.PickupLong] = pickupLong
        }
        if let dropoffLat = params.dropoffLat, let dropoffLong = params.dropoffLong {
            param[Constants.PromotionParams.DropoffLat] = dropoffLat
            param[Constants.PromotionParams.DropoffLong] = dropoffLong
        }
        param[Constants.PromotionParams.DateTime] = params.dateTime
        
        let url = (Constants.APIURL.Promotions + "?" + param.queryString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        self.get(url: url, param: nil, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
    }
}
