//
//  KTCancelBookingManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/4/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

let CANCEL_REASON_SYNC_TIME = "CancelReasonSyncTime"

class KTCancelBookingManager: KTDALManager {
    
    func fetchCancelReasons() {
        fetchCancelReasons { (status, response) in
            print(response)
        }
    }
    
    func fetchCancelReasons(completion completionBlock: @escaping KTDALCompletionBlock) {
        let param : [String: Any] = [Constants.SyncParam.CancelReason: syncTime(forKey: CANCEL_REASON_SYNC_TIME)]
        self.get(url: Constants.APIURL.CancelReason, param: param, completion: completionBlock) { (response, cBlock) in
            
            //First remove all data from the table.
        
            
            self.saveCancelReasons(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: CANCEL_REASON_SYNC_TIME)
        }
    }
    
    private func saveCancelReasons(response : [Any]){
        guard response.count > 0 else {
            return
        }
        
        KTCancelReason.mr_truncateAll()
        
        for r in response {
            
            self.saveSingleReason(reason: r as! [AnyHashable: Any])
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    private func saveSingleReason(reason : [AnyHashable: Any]) {
        
        //let comaSapratedBookingStatii : String = reason[Constants.CancelReasonAPIKey.BookingStatii] as! String
        for statii in reason[Constants.CancelReasonAPIKey.BookingStatii] as! [Int]{
            for descKey in (reason[Constants.CancelReasonAPIKey.Desc] as! [String: String]).keys {
                saveReason(statii: Int32(statii), language: descKey, desc: (reason[Constants.CancelReasonAPIKey.Desc] as! [AnyHashable: String])[descKey]!, reasonCode: reason[Constants.CancelReasonAPIKey.ReasonCode] as! Int16)
            }
        }
    }
    
    private func saveReason(statii: Int32, language: String, desc: String, reasonCode: Int16) {
        let reason : KTCancelReason = KTCancelReason.mr_createEntity()!
        reason.bookingStatii = statii
        reason.language = language
        reason.desc = desc
        reason.reasonCode = reasonCode
    }
    
    func cencelReasons(forBookingStatii statii:Int32) -> [KTCancelReason]{
        
        let perdicate = NSPredicate(format: "bookingStatii == %d AND language == %@",statii,"EN")
        let reasons : [KTCancelReason] = KTCancelReason.mr_findAll(with: perdicate) as! [KTCancelReason]
        //let reasons : [KTCancelReason] = KTCancelReason.mr_findAll() as! [KTCancelReason]
        return reasons
    }
}
