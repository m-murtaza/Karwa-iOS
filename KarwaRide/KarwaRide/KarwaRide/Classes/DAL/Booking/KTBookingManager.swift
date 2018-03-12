//
//  KTBookingManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

let BOOKING_SYNC_TIME = "bookingSyncTime"

class KTBookingManager: KTDALManager {
    
    func booking(pickUp: KTGeoLocation?, dropOff:KTGeoLocation?) -> KTBooking {
        
        let book : KTBooking = KTBooking.mr_createEntity(in: NSManagedObjectContext.mr_default())!
        book.pickupLocation = pickUp
        if dropOff != nil {
            book.dropoffLocation = dropOff
        }
        
        return book
    }
    
    func bookTaxi(job: KTBooking, completion completionBlock: @escaping KTDALCompletionBlock)  {
        
        let param : NSDictionary = [Constants.BookingParams.PickLocation: job.pickupLocation!.name!,
                                    Constants.BookingParams.PickLat: job.pickupLocation!.latitude,
                                    Constants.BookingParams.PickLon: job.pickupLocation!.longitude,
                                    Constants.BookingParams.PickTime: job.pickupTime!,
                                    Constants.BookingParams.DropLocation: (job.dropoffLocation != nil) ? job.dropoffLocation!.name! : "",
                                    Constants.BookingParams.DropLat : (job.dropoffLocation != nil) ? job.dropoffLocation!.latitude : 0.0,
                                    Constants.BookingParams.DropLon : (job.dropoffLocation != nil) ? job.dropoffLocation!.longitude : 0.0,
                                    Constants.BookingParams.CreationTime : job.creationTime!,
                                    Constants.BookingParams.PickHint : job.pickupHint!,
                                    Constants.BookingParams.VehicleType : job.vehicleType,
                                    Constants.BookingParams.CallerID : job.callerId!]
        
        
        self.post(url: Constants.APIURL.Booking, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            
            completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            
        })
    }
    
    func syncBookings(completion completionBlock: @escaping KTDALCompletionBlock) {
        
        let param : [String: Any] = [Constants.BookingSyncParam.SyncTime: bookingSyncTime()]
        
        self.get(url: Constants.APIURL.Booking, param: param, completion: completionBlock) { (response, cBlock) in
            print(response)
        }
    }
    
    
    //MARK: - Booking Sync Time
    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
    func bookingSyncTime() -> String {
        var syncDate = UserDefaults.standard.object(forKey: BOOKING_SYNC_TIME) as? Date
        if syncDate == nil {
            syncDate = self.defaultSyncDate()
        }
        let syncTimeInterval: TimeInterval = (syncDate?.timeIntervalSince1970)!
        let strSyncTimeInterval = "\(syncTimeInterval)"
        return strSyncTimeInterval
    }
    
    func updateBookingSyncTime() {
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(Date(), forKey: BOOKING_SYNC_TIME)
        defaults?.synchronize()
    }
    
    func removeSyncTime() {
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.removeObject(forKey: BOOKING_SYNC_TIME)
        defaults?.synchronize()
    }
    
    func defaultSyncDate() -> Date? {
        return Date(timeIntervalSince1970: 0)
        //Default date of 1970
    }

}
