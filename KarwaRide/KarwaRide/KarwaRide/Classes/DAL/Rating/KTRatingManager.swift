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
    
    func ratingReasonsAvalible() -> Bool {
        guard let rReasons = ratingReasons(), rReasons.count > 0 else {
            print("Rating Reasons Not Available")
            return false
        }
        return true
    }
    
    func fetchInitialRatingReasonsLocal() {
        if !ratingReasonsAvalible(){
            //Rating Reason not available
            do {
                
                if let file = Bundle.main.url(forResource: "InitRatingReasons", withExtension: "JSON") {
                    let data = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [String: Any] {
                        // json is a dictionary
                        self.saveRatingReasons(response: object[Constants.ResponseAPIKey.Data] as! [Any])
                    }
                }
            }
            catch {
                print("error.localizedDescription")
            }
        }
        
    }
    
    
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
        for rating in reason[Constants.RatingReasonAPIKey.Ratings] as! [Int]
        {
            for descKey in (reason[Constants.RatingReasonAPIKey.Desc] as! [String: String]).keys
            {
                var isComplainableRating = false
                if(reason[Constants.RatingReasonAPIKey.ComplainableRating] != nil)
                {
                    for complainableRating in reason[Constants.RatingReasonAPIKey.ComplainableRating] as! [Int]
                    {
                        if(complainableRating == Int32(rating))
                        {
                            isComplainableRating = true
                            break
                        }
                    }
                }

                saveReason(
                    rating: Int32(rating),
                    language: descKey,
                    desc: (reason[Constants.RatingReasonAPIKey.Desc] as! [AnyHashable: String])[descKey]!,
                    reasonCode: reason[Constants.RatingReasonAPIKey.ReasonCode] as! Int16,
                    isComplainableRating: isComplainableRating
                )
            }
        }
    }
    
    private func saveReason(rating: Int32, language: String, desc: String, reasonCode: Int16, isComplainableRating: Bool) {
        let reason : KTRatingReasons = KTRatingReasons.mr_createEntity()!
        reason.rating = rating
        reason.language = language
        reason.desc = desc
        reason.isComplainable = isComplainableRating
        reason.reasonCode = reasonCode
    }
    
    func ratingReasons() -> [KTRatingReasons]?{
        
        let reasons : [KTRatingReasons] = KTRatingReasons.mr_findAll() as! [KTRatingReasons]
        
        return reasons
    }
    
    func ratingsReason(forRating rating: Int32, language: String) -> [KTRatingReasons]? {
        
        let predicate : NSPredicate = NSPredicate(format: "rating == %d && language = %@", rating , language)
        let reasons : [KTRatingReasons] = KTRatingReasons.mr_findAll(with: predicate) as! [KTRatingReasons] 
        return reasons
    }
    
    func rateBooking(forId bookingId:String,rating: Int32 ,reasons: [Int16], tripType: Int16, completion completionBlock:@escaping KTDALCompletionBlock)  {
        let param : [String: Any] = [Constants.RatingParams.Rating: rating,
                                     Constants.RatingParams.Reasons: reasons,
                                     Constants.RatingParams.TripType: tripType]
        let url : String = Constants.APIURL.RateBooking + "/" + bookingId
        
        self.post(url: url, param: param, completion: completionBlock) {
            (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
}
