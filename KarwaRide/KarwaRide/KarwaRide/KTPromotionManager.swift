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
}
