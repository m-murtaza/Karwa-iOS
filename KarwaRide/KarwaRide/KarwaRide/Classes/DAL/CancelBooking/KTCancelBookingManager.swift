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
    func fetchCancelReasons(completion completionBlock: @escaping KTDALCompletionBlock) {
        let param : [String: Any] = [Constants.SyncParam.CancelReason: syncTime(forKey: CANCEL_REASON_SYNC_TIME)]
        self.get(url: Constants.APIURL.CancelReason, param: param, completion: completionBlock) { (response, cBlock) in
            print(response)
            //self.saveInitTariff(response: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: CANCEL_REASON_SYNC_TIME)
        }
    }
}
