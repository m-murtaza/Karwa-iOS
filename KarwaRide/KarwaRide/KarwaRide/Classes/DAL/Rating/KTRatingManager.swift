//
//  KTRatingReason.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

let RATING_REASON_SYNC_TIME = "RatingReasonSyncTime"

class KTRatingManager: KTDALManager {

    func fetchRatingReasons() {
        fetchRatingReasons { (status, response) in
            print(response)
        }
    }
    
    func fetchRatingReasons(completion completionBlock: @escaping KTDALCompletionBlock) {
        let param : [String: Any] = [Constants.SyncParam.RatingReason: syncTime(forKey: RATING_REASON_SYNC_TIME)]
        self.get(url: Constants.APIURL.RatingReason, param: param, completion: completionBlock) { (response, cBlock) in
            
            //First remove all data from the table.
            //print(response)
            
            self.saveRatingReasons(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: RATING_REASON_SYNC_TIME)
        }
    }
    
    private func saveRatingReasons(response : [Any]){
        guard response.count > 0 else {
            return
        }
        
        KTRatingReasons.mr_truncateAll()
        
        for r in response {
            
            self.saveSingleReason(reason: r as! [AnyHashable: Any])
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    private func saveSingleReason(reason : [AnyHashable: Any]) {
        
        //let comaSapratedBookingStatii : String = reason[Constants.CancelReasonAPIKey.BookingStatii] as! String
        for rating in reason[Constants.RatingReasonAPIKey.Ratings] as! [Int]{
            for descKey in (reason[Constants.RatingReasonAPIKey.Desc] as! [String: String]).keys {
                saveReason(rating: Int32(rating), language: descKey, desc: (reason[Constants.RatingReasonAPIKey.Desc] as! [AnyHashable: String])[descKey]!, reasonCode: reason[Constants.RatingReasonAPIKey.ReasonCode] as! Int16)
            }
        }
    }
    
    private func saveReason(rating: Int32, language: String, desc: String, reasonCode: Int16) {
        let reason : KTRatingReasons = KTRatingReasons.mr_createEntity()!
        reason.rating = rating
        reason.language = language
        reason.desc = desc
        reason.reasonCode = reasonCode
    }
    
    
}
