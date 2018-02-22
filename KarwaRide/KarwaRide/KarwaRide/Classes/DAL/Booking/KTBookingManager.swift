//
//  KTBookingManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

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
}
