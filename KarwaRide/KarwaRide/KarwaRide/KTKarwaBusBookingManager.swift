//
//  KTKarwaBusBookingManager.swift
//  KarwaRide
//
//  Created by Apple on 19/01/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation

import UIKit

let BUS_SYNC_TIME = "BusSyncTime"

class KTKarwaBusBookingManager: KTBaseFareEstimateManager {
    
    func getRoutesWithSync(requestParameter: RequestParameters, completion completionBlock: @escaping KTDALCompletionBlock) {
        
        self.resetSyncTime(forKey: BUS_SYNC_TIME)
        
//        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:BUS_SYNC_TIME)]
        
        let param: [String: Any] =  ["mode":"TRANSIT,WALK",
                                     "arriveBy":"false",
                                     "wheelchair":"false",
                                     "debugItineraryFilter":"false",
                                     "fromPlace":"25.19251511519153,51.503562927246094",
                                     "toPlace":"25.2468696669746,51.56261444091796",
                                     "maxWalkDistance":"4828.032",
                                     "locale":"en"]
                
        //https://consumer.karwatechnologies.com/plan?fromPlace=25.19251511519153%2C51.503562927246094&toPlace=25.2468696669746%2C51.56261444091796&time=6%3A00pm&date=01-18-2022&mode=TRANSIT%2CWALK&maxWalkDistance=NaN&arriveBy=false&wheelchair=false&debugItineraryFilter=false&locale=en
        self.get(url: Constants.APIURL.GetRoutePlan, param: param, completion: completionBlock) { (response, cBlock) in
            
            print(response)
                        
            self.updateSyncTime(forKey: BUS_SYNC_TIME)
            
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
                
}
