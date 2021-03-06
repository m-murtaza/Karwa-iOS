//
//  KTBookingManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

let BOOKING_SYNC_TIME = "BookingSyncTime"
let XPRESS_BOOKING_SYNC_TIME = "XpressBookingSyncTime"

class KTBookingManager: KTBaseFareEstimateManager {
    
    func booking() -> KTBooking {
        
        let book : KTBooking = KTBooking.mr_createEntity(in: NSManagedObjectContext.mr_default())!
        
        
        book.bookingStatus = BookingStatus.UNKNOWN.rawValue
        return book
    }
    
    func bookTaxi(job: KTBooking, estimate: KTFareEstimate?, promo: String, completion completionBlock: @escaping KTDALCompletionBlock)  {
        
        let param : NSMutableDictionary = [Constants.BookingParams.PickLocation: job.pickupAddress!,
                                    Constants.BookingParams.PickLat: job.pickupLat,
                                    Constants.BookingParams.PickLon: job.pickupLon,
                                    Constants.BookingParams.PickLocationID : job.pickupLocationId,
                                    Constants.BookingParams.DropLocation: (job.dropOffAddress != nil) ? job.dropOffAddress as Any : "",
                                    Constants.BookingParams.DropLat : job.dropOffLat,
                                    Constants.BookingParams.DropLon : job.dropOffLon,
                                    Constants.BookingParams.DropLocationId : job.dropOffLocationId,
                                    Constants.BookingParams.PickHint : job.pickupMessage!,
                                    Constants.BookingParams.VehicleType : job.vehicleType,
                                    Constants.BookingParams.CallerID : job.callerId!,
                                    Constants.BookingParams.EstimateId : (estimate != nil) ? (estimate!.estimateId)! : 0,
                                    Constants.BookingParams.PromoCode : promo]
        
        if job.paymentMethod?.count != 0 {
            param[Constants.BookingParams.PaymentSource] = job.paymentMethod ?? ""
        }

        if #available(iOS 13.0, *) {
            if(Date().distance(to: job.pickupTime!) > 300) // Skipping time for current booking
            {
                param[Constants.BookingParams.PickTime] = job.pickupTime!.sanitizedTime()
                param[Constants.BookingParams.CreationTime] = job.creationTime!
            }
        } else {
            param[Constants.BookingParams.PickTime] = job.pickupTime!.sanitizedTime()
            param[Constants.BookingParams.CreationTime] = job.creationTime!
        }

        self.post(url: Constants.APIURL.Booking, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            
            
            DispatchQueue.main.async {
                job.bookingId = responseData[Constants.BookingParams.BookingId] as? String
                job.bookingStatus = (responseData[Constants.BookingParams.Status] as? Int32)!
                job.bookingType = (responseData[Constants.BookingParams.BookingType] as? Int16)!
                job.estimatedFare = responseData[Constants.BookingParams.EstimatedFare] as? String
                job.trackId = responseData[Constants.BookingParams.TrackId] as? String
                job.tripType = responseData[Constants.BookingParams.TripType] as? Int16 ?? 1
                job.otp = responseData[Constants.BookingParams.Otp] as? String
         
                if estimate != nil {
                    let kv : KTKeyValue = KTBaseFareEstimateManager().keyValue(forKey: "Booking ID", value: job.bookingId!)

                    if let header = estimate?.toKeyValueHeader {
                        estimate?.toKeyValueHeader = header.adding(kv)
                    }

                    let bookingEstimate = estimate?.managedObjectContext?.object(with: job.objectID)
                    job.bookingToEstimate = bookingEstimate as? KTFareEstimate
    //                estimate?.fareestimateToBooking = job
                    
                }
                self.saveInDb()
                
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
            
            
            
        })
    }
    
    func syncBookings(completion completionBlock: @escaping KTDALCompletionBlock) {
        
        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:BOOKING_SYNC_TIME)]
        
        self.get(url: Constants.APIURL.Booking, param: param, completion: completionBlock) { (response, cBlock) in
            
            let bookings = self.saveBookingsInDB(bookings: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: BOOKING_SYNC_TIME)
            
            cBlock(Constants.APIResponseStatus.SUCCESS,[Constants.ResponseAPIKey.Data:bookings])
        }
    }
    
    func syncXpressBookings(orderId: String, completion completionBlock: @escaping KTDALCompletionBlock) {
        
        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:XPRESS_BOOKING_SYNC_TIME)]
        
        self.get(url: Constants.APIURL.Booking + "/\(orderId)", param: param, completion: completionBlock) { (response, cBlock) in
            
            let bookings = self.saveBookingInDB(booking: response )
            self.updateSyncTime(forKey: XPRESS_BOOKING_SYNC_TIME)
            
            cBlock(Constants.APIResponseStatus.SUCCESS,[Constants.ResponseAPIKey.Data: bookings])
        }
    }
    
    func saveBookingsInDB(bookings : [Any]) -> [KTBooking]  {
        var arrBookings : [KTBooking] = []
        for booking in bookings {
            
            arrBookings.append(saveBookingInDB(booking: booking as!  [AnyHashable : Any]))
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        return arrBookings
    }
    
    func saveBookingInDB(booking :[AnyHashable: Any]) -> KTBooking {
            
        let b : KTBooking = KTBooking.obj(withValue: booking[Constants.BookingResponseAPIKey.BookingID]!, forAttrib: "bookingId", inContext: NSManagedObjectContext.mr_default()) as! KTBooking
        
        b.bookingStatus = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.BookingStatus] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.BookingStatus] as! Int32 : 0
        b.cancelReason = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CancelReason] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.CancelReason] as! Int32 : 0
        b.bookingStatus = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.BookingStatus] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.BookingStatus] as! Int32 : 0
        b.creationTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CreationTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.CreationTime] as? String)  : Date.defaultDate() 
        
        b.callerId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CallerID] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.CallerID] as? String : ""
        b.eta = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Eta] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Eta] as! Int64 : 0
        b.estimatedFare = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.EstimatedFare] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.EstimatedFare] as? String : ""

        b.fare = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Fare] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Fare] as? String : ""
        b.cancellationCharges = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.cancellationCharges] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.cancellationCharges] as? String : ""

        b.driverId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverID] as AnyObject)) ? String("\(booking[Constants.BookingResponseAPIKey.DriverID] ?? "")") : ""
        
        b.driverTip = Int16((!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Tip] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Tip] as! Int : 0)
        
        b.driverName = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverName] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverName] as? String : ""
        b.driverPhone = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverPhone] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverPhone] as? String : ""
        b.driverRating = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverRating] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverRating] as! Double : 0.0
        
        b.dropOffAddress = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropAddress] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropAddress] as? String : ""
        b.dropOffLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropLat] as! Double : 0.0
        b.dropOffLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropLon] as! Double : 0.0
        b.dropOffTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.DropTime] as? String) : Date.defaultDate()
        
        b.pickupAddress = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupAddress] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupAddress] as? String : ""
        b.pickupLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupLat] as! Double : 0.0
        b.pickupLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupLon] as! Double : 0.0
        b.pickupMessage = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupMessage] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupMessage] as? String : ""
        b.pickupTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.PickupTime] as? String): Date.defaultDate()
        b.pickStopLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickStopLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickStopLat] as! Double : 0.0
        b.pickStopLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickStopLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickStopLon] as! Double : 0.0

        b.dropStopLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.dropStopLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.dropStopLat] as! Double : 0.0
        b.dropStopLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.dropStopLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.dropStopLon] as! Double : 0.0

        b.serviceType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.ServiceType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.ServiceType] as! Int16 : 0
        b.totalDistance = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TotalDistance] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TotalDistance] as? String : ""
        b.tripTrack = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Track] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Track] as? String : ""
        
        b.vehicleNo =  (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.VehicleNo] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.VehicleNo] as? String : ""
        b.vehicleType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.VehicleType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.VehicleType] as! Int16 : 0
        
        if self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.VehicleNo] as AnyObject) {
            if let plateType = booking[Constants.BookingResponseAPIKey.PlateType] as? Int16 {
                b.plateType = plateType
            } else {
                b.plateType = -1
            }
        }
        
        b.encodedPath =  (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.EncodedPath] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.EncodedPath] as? String : ""
        
        if(!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TripSummary] as AnyObject)) {
            let data = booking[Constants.BookingResponseAPIKey.TripSummary] as! [AnyHashable:Any]
            if let value = data["Total Fare"]
            {
                b.totalFare = value as? String ?? "0"
            }
            self.saveTripSummey(data: data,booking: b )
        }
        
        b.isRated = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.IsRated] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.IsRated] as! Bool : false
        
        b.paymentMethod = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PaymentMethod] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PaymentMethod] as? String : ""
        b.lastFourDigits = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.LastFourDigits] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.LastFourDigits] as? String : ""

        b.trackId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TrackId] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TrackId] as! String : ""

        b.tripType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TripType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TripType] as! Int16 : 1
        
        b.passengerCount = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PassengerCount] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PassengerCount] as! Int16 : 1

        b.otp = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.OTP] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.OTP] as? String : ""
        
        b.desc = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Desc] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Desc] as? String : ""


        return b
    }
    
    func saveTripSummey(data: [AnyHashable: Any], booking: KTBooking) {
        for keyvalue in booking.toKeyValueBody! {
            (keyvalue as! KTKeyValue).mr_deleteEntity()
        }
        booking.toKeyValueBody = NSOrderedSet()

        if let value = data["Body"]
        {
            KTBaseFareEstimateManager().saveKeyValueBody(keyValue: value as! [[AnyHashable : Any]], tariff: booking as KTBaseTrariff)
        }

        for keyvalue in booking.toKeyValueHeader! {
            (keyvalue as! KTKeyValue).mr_deleteEntity()
        }
        booking.toKeyValueHeader = NSOrderedSet()
        KTBaseFareEstimateManager().saveKeyValueHeader(keyValue: data["Header"] as! [[AnyHashable : Any]], tariff: booking as KTBaseTrariff)
    }
    
    func pendingXpressBookings() -> [KTBooking] {
        
        var bookings : [KTBooking] = []
        
        let newPredicate : NSPredicate = NSPredicate(format:"bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d",BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue)
        let predicate : NSPredicate = NSPredicate(format:"vehicleType == %d","200")
        
        bookings.append(contentsOf: KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: newPredicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking])
        bookings.append(contentsOf: KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking])

        return bookings
    }
    
    func historyXpressBookings() -> [KTBooking] {
        var bookings : [KTBooking] = []
        let predicate : NSPredicate = NSPredicate(format:"bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND vehicleType == %d" , BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue,BookingStatus.UNKNOWN.rawValue, 200)
        
        bookings = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking]
        
        return bookings
    }
    
    
    func pendingBookings() -> [KTBooking] {
        
        var bookings : [KTBooking] = []
        let predicate : NSPredicate = NSPredicate(format:"bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d",BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue)
        
        bookings = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking]
//        let filterdBookings = bookings.filter{$0.vehicleType != 200}
                
        return bookings
        
    }
    
    func historyBookings() -> [KTBooking] {
        var bookings : [KTBooking] = []
        let predicate : NSPredicate = NSPredicate(format:"bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d" , BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue,BookingStatus.UNKNOWN.rawValue)
        
        bookings = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking]
        
        return bookings
    }
    
    func getBooking(bookingId id : String) -> KTBooking
    {
        var booking : KTBooking
        let predicate : NSPredicate = NSPredicate(format:"bookingId != %d" , id)
        
//        booking = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! KTBooking
        booking = KTBooking.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())!
        
        return booking
    }
    
    //MARK: - Booking Sync Time
    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
//    func bookingSyncTime() -> String {
//        var syncDate = UserDefaults.standard.object(forKey: BOOKING_SYNC_TIME) as? Date
//        if syncDate == nil {
//            syncDate = self.defaultSyncDate()
//        }
//        let syncTimeInterval: TimeInterval = (syncDate?.timeIntervalSince1970)!
//        let strSyncTimeInterval = String(format: "%.0f", syncTimeInterval)
//        return strSyncTimeInterval
//    }
//
//    func updateBookingSyncTime() {
//        let defaults: UserDefaults? = UserDefaults.standard
//        defaults?.set(Date(), forKey: BOOKING_SYNC_TIME)
//        defaults?.synchronize()
//    }
//
//    func removeSyncTime() {
//        let defaults: UserDefaults? = UserDefaults.standard
//        defaults?.removeObject(forKey: BOOKING_SYNC_TIME)
//        defaults?.synchronize()
//    }
//
//    func defaultSyncDate() -> Date? {
//        return Date(timeIntervalSince1970: 0)
//        //Default date of 1970
//    }

    func booking(forBookingID bookingId: String, completion completionBlock:@escaping KTDALCompletionBlock) {
        booking(bookingId, false, completion: completionBlock)
    }
    
    func booking(_ id: String, _ isBookingId: Bool, completion completionBlock:@escaping KTDALCompletionBlock) {
        let url = (isBookingId ? Constants.APIURL.Booking : Constants.APIURL.Track) + "/" + id
        self.get(url: url, param: nil, completion: completionBlock) { (response, cBlock) in
            let booking : KTBooking = self.saveBookingInDB(booking: response as [AnyHashable : Any])
            
            cBlock(Constants.APIResponseStatus.SUCCESS, [Constants.ResponseAPIKey.Data: booking])
        }
    }
}
