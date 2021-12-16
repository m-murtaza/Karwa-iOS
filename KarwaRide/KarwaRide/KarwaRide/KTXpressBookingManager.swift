//
//  XpressBookingManager.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 20/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

import UIKit

let ZONE_SYNC_TIME = "ZoneSyncTime"

class KTXpressBookingManager: KTBaseFareEstimateManager {
    
    func getZoneWithSync(completion completionBlock: @escaping KTDALCompletionBlock) {
        
        self.resetSyncTime(forKey: ZONE_SYNC_TIME)

        //syncTime(forKey:ZONE_SYNC_TIME)
        
        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:ZONE_SYNC_TIME)]
                
        self.get(url: Constants.APIURL.GetRSAreas, param: param, completion: completionBlock) { (response, cBlock) in
            
            print(response)
            
            if let totalOperatingResponse = response["Response"] as? [String: Any] {
                
                print(totalOperatingResponse)
                
                if let totalAreas = totalOperatingResponse["Areas"] as? [[String:Any]] {
                    
                    print(totalAreas)
                    
                    areas.removeAll()

                    for item in totalAreas {
                        
                        print(item)
                        
                        let area = Area(code: (item["Code"] as? Int) ?? 0, vehicleType:(item["VehicleType"] as? Int) ?? -1, name: (item["Name"] as? String) ?? "", parent: (item["Parent"] as? Int) ?? -1, bound: (item["Bound"] as? String) ?? "", type: (item["Type"] as? String) ?? "", isActive: (item["IsActive"] as? Bool) ?? false)
                        
                        areas.append(area)
                                                
                    }
                
                                                            
                }
                zones.removeAll()
                metroStopsArea.removeAll()
                metroStations.removeAll()
                tramStopsArea.removeAll()
                tramStations.removeAll()
                
                zones = areas.filter{$0.type == "Zone"}
                metroStopsArea = areas.filter{$0.type! == "MetroStop"}
                metroStations = areas.filter{$0.type! == "MetroStation"}
                tramStopsArea = areas.filter{$0.type! == "TramStop"}
                tramStations = areas.filter{$0.type! == "TramStation"}

                for zone in zones {
                    
                    var z  = [String: [Area]]()
                    z["zone"] = [zone]
                    var stations = metroStations.filter{$0.parent! == zone.code!}
                    stations.append(contentsOf: tramStations.filter{$0.parent! == zone.code!})
                    z["stations"] = stations
                    zonalArea.append(z)
                    
                }
                
                for item in zonalArea {
                    print("Zonal Area", item)
                }
                
                destinations.removeAll()
                
                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {
                        
                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        destinations.append(destination)
                                                
                    }
                                
                }
                                                
                var localPickUpArea = [Area]()
                
                for item in tramStopsArea {
                    
                    if let pickUpLocation = destinations.filter({$0.source! == item.parent!}).first {
                        if localPickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
                            
                        } else {
                            localPickUpArea.append(item)
                        }
                    }
                    
                }
                
                let set1: Set<Area> = Set(metroStopsArea)
                let set2: Set<Area> = Set(tramStopsArea)

                stops.removeAll()
                    
                stops = Array(set1.union(set2))

            }
            
//            let bookings = self.saveBookingsInDB(bookings: response[Constants.ResponseAPIKey.Data] as! [Any])
            self.updateSyncTime(forKey: ZONE_SYNC_TIME)
            
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    func getRideService(rideData: RideSerivceLocationData, completion completionBlock: @escaping KTDALCompletionBlock) {
        
        //syncTime(forKey:ZONE_SYNC_TIME)
        
        /*
         {
             "Pick":{
                 "Location":{
                         "Lat":25.512321,"Lon":51.56343
                 },
                 "Zone":32,
                 "Station":12,
                 "Stop":32,
                 "Name": "Dalla driving school"
             },
             "Drop":{
                 "Location":{
                         "Lat":25.4321,"Lon":51.2312
                 },
                 "Zone":32,
                 "Station":12,
                 "Stop":32,
                 "Name": "Al awab"
             },
             "PassengerCount":2
         }
         */
        
        var param  = [String: Any]()
        
        var pickAddress  = ""
        var dropAddress  = ""

        if rideData.pickUpStop != nil {
            pickAddress = rideData.pickUpStop?.name ?? ""
        } else if rideData.pickUpStop != nil {
            pickAddress = rideData.pickUpStation?.name ?? ""
        }  else if rideData.pickUpZone != nil {
            pickAddress = rideData.pickUpZone?.name ?? ""
        }
        
        if rideData.dropOffStop != nil {
            dropAddress = rideData.dropOffStop?.name ?? ""
        } else if rideData.dropOfSftation != nil {
            dropAddress = rideData.dropOfSftation?.name ?? ""
        }  else if rideData.dropOffZone != nil {
            dropAddress = rideData.dropOffZone?.name ?? ""
        }
        
        let pickUpLocationData = ["Location": ["Lat": "\(rideData.pickUpCoordinate?.latitude ?? 0.0)", "Lon": "\(rideData.pickUpCoordinate?.longitude ?? 0.0)"], "Zone": rideData.pickUpZone?.code ?? "", "Station": rideData.pickUpStation?.code ?? "", "Stop": rideData.pickUpStop?.code ?? "", "Name": pickAddress] as [String : Any]
        //
        let dropOffLocationData = ["Location": ["Lat": "\(rideData.dropOffCoordinate?.latitude ?? 0.0)", "Lon": "\(rideData.dropOffCoordinate?.longitude ?? 0.0)"], "Zone": rideData.dropOffZone?.code ?? "", "Station": rideData.dropOfSftation?.code ?? "", "Stop": rideData.dropOffStop?.code ?? "", "Name": dropAddress] as [String : Any]
        //
        param["Pick"] = pickUpLocationData
        param["Drop"] = dropOffLocationData
        param["PassengerCount"] = rideData.passsengerCount ?? 1

        self.post(url: Constants.APIURL.PostRSService, param: param, completion: completionBlock) { (response, cBlock) in
            print("response", response)
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
        
    }
    
    func getOrderStatus(vehicleInfo: RideVehiceInfo, completion completionBlock: @escaping KTDALCompletionBlock) {
        self.post(url: Constants.APIURL.orderService + "\(vehicleInfo.id ?? "")", param: nil, completion: completionBlock) { (response, cBlock) in
            print(response)
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    func getOrderPollingStatus(vehicleInfo: RideVehiceInfo, completion completionBlock: @escaping KTDALCompletionBlock) {
        self.get(url: Constants.APIURL.orderService + "\(vehicleInfo.id ?? "")/status", param: nil, completion: completionBlock) { (response, cBlock) in
            print(response)
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
//    func booking() -> KTBooking {
//
//        let book : KTBooking = KTBooking.mr_createEntity(in: NSManagedObjectContext.mr_default())!
//
//
//        book.bookingStatus = BookingStatus.UNKNOWN.rawValue
//        return book
//    }
//
//    func bookTaxi(job: KTBooking, estimate: KTFareEstimate?, promo: String, completion completionBlock: @escaping KTDALCompletionBlock)  {
//
//        let param : NSMutableDictionary = [Constants.BookingParams.PickLocation: job.pickupAddress!,
//                                    Constants.BookingParams.PickLat: job.pickupLat,
//                                    Constants.BookingParams.PickLon: job.pickupLon,
//                                    Constants.BookingParams.PickLocationID : job.pickupLocationId,
//                                    Constants.BookingParams.DropLocation: (job.dropOffAddress != nil) ? job.dropOffAddress as Any : "",
//                                    Constants.BookingParams.DropLat : job.dropOffLat,
//                                    Constants.BookingParams.DropLon : job.dropOffLon,
//                                    Constants.BookingParams.DropLocationId : job.dropOffLocationId,
//                                    Constants.BookingParams.PickHint : job.pickupMessage!,
//                                    Constants.BookingParams.VehicleType : job.vehicleType,
//                                    Constants.BookingParams.CallerID : job.callerId!,
//                                    Constants.BookingParams.EstimateId : (estimate != nil) ? (estimate!.estimateId)! : 0,
//                                    Constants.BookingParams.PromoCode : promo]
//
//        if #available(iOS 13.0, *) {
//            if(Date().distance(to: job.pickupTime!) > 300) // Skipping time for current booking
//            {
//                param[Constants.BookingParams.PickTime] = job.pickupTime!.sanitizedTime()
//                param[Constants.BookingParams.CreationTime] = job.creationTime!
//            }
//        } else {
//            param[Constants.BookingParams.PickTime] = job.pickupTime!.sanitizedTime()
//            param[Constants.BookingParams.CreationTime] = job.creationTime!
//        }
//
//        self.post(url: Constants.APIURL.Booking, param: param as? [String : Any], completion: completionBlock, success: {
//            (responseData,cBlock) in
//            job.bookingId = responseData[Constants.BookingParams.BookingId] as? String
//            job.bookingStatus = (responseData[Constants.BookingParams.Status] as? Int32)!
//            job.bookingType = (responseData[Constants.BookingParams.BookingType] as? Int16)!
//            job.estimatedFare = responseData[Constants.BookingParams.EstimatedFare] as? String
//            job.trackId = responseData[Constants.BookingParams.TrackId] as? String
//            job.tripType = responseData[Constants.BookingParams.TripType] as? Int16 ?? 1
//
//            let vType : KTVehicleType = (KTVehicleTypeManager().vehicleType(typeId: job.vehicleType))!
//            job.toKeyValueHeader = vType.toKeyValueHeader
//            job.toKeyValueBody = vType.toKeyValueBody
//
//            if estimate != nil {
//                let kv : KTKeyValue = KTBaseFareEstimateManager().keyValue(forKey: "Booking ID", value: job.bookingId!)
//
//                estimate?.toKeyValueHeader = estimate?.toKeyValueHeader!.adding(kv)
//                job.bookingToEstimate = estimate
//                estimate?.fareestimateToBooking = job
//
//            }
//            self.saveInDb()
//
//            completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
//        })
//    }
//
//    func syncBookings(completion completionBlock: @escaping KTDALCompletionBlock) {
//
//        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:BOOKING_SYNC_TIME)]
//
//        self.get(url: Constants.APIURL.Booking, param: param, completion: completionBlock) { (response, cBlock) in
//
//            let bookings = self.saveBookingsInDB(bookings: response[Constants.ResponseAPIKey.Data] as! [Any])
//            self.updateSyncTime(forKey: BOOKING_SYNC_TIME)
//
//            cBlock(Constants.APIResponseStatus.SUCCESS,[Constants.ResponseAPIKey.Data:bookings])
//        }
//    }
//
//    func saveBookingsInDB(bookings : [Any]) -> [KTBooking]  {
//        var arrBookings : [KTBooking] = []
//        for booking in bookings {
//
//            arrBookings.append(saveBookingInDB(booking: booking as!  [AnyHashable : Any]))
//        }
//        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
//        return arrBookings
//    }
//
//    func saveBookingInDB(booking :[AnyHashable: Any]) -> KTBooking {
//
//        let b : KTBooking = KTBooking.obj(withValue: booking[Constants.BookingResponseAPIKey.BookingID]!, forAttrib: "bookingId", inContext: NSManagedObjectContext.mr_default()) as! KTBooking
//
//        b.bookingStatus = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.BookingStatus] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.BookingStatus] as! Int32 : 0
//        b.cancelReason = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CancelReason] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.CancelReason] as! Int32 : 0
//        b.bookingStatus = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.BookingStatus] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.BookingStatus] as! Int32 : 0
//        b.creationTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CreationTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.CreationTime] as? String)  : Date.defaultDate()
//
//        b.callerId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.CallerID] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.CallerID] as? String : ""
//        b.eta = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Eta] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Eta] as! Int64 : 0
//        b.estimatedFare = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.EstimatedFare] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.EstimatedFare] as? String : ""
//
//        b.fare = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Fare] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Fare] as? String : ""
//
//        b.driverId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverID] as AnyObject)) ? String("\(booking[Constants.BookingResponseAPIKey.DriverID] ?? "")") : ""
//
//
//        b.driverName = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverName] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverName] as? String : ""
//        b.driverPhone = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverPhone] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverPhone] as? String : ""
//        b.driverRating = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DriverRating] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DriverRating] as! Double : 0.0
//
//        b.dropOffAddress = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropAddress] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropAddress] as? String : ""
//        b.dropOffLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropLat] as! Double : 0.0
//        b.dropOffLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.DropLon] as! Double : 0.0
//        b.dropOffTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.DropTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.DropTime] as? String) : Date.defaultDate()
//
//        b.pickupAddress = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupAddress] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupAddress] as? String : ""
//        b.pickupLat = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupLat] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupLat] as! Double : 0.0
//        b.pickupLon = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupLon] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupLon] as! Double : 0.0
//        b.pickupMessage = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupMessage] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PickupMessage] as? String : ""
//        b.pickupTime = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PickupTime] as AnyObject)) ? Date.dateFromServerString(date: booking[Constants.BookingResponseAPIKey.PickupTime] as? String): Date.defaultDate()
//
//        b.serviceType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.ServiceType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.ServiceType] as! Int16 : 0
//        b.totalDistance = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TotalDistance] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TotalDistance] as? String : ""
//        b.tripTrack = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.Track] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.Track] as? String : ""
//
//        b.vehicleNo =  (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.VehicleNo] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.VehicleNo] as? String : ""
//        b.vehicleType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.VehicleType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.VehicleType] as! Int16 : 0
//
//        b.encodedPath =  (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.EncodedPath] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.EncodedPath] as? String : ""
//
//        if(!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TripSummary] as AnyObject)) {
//            let data = booking[Constants.BookingResponseAPIKey.TripSummary] as! [AnyHashable:Any]
//            if let value = data["Total Fare"]
//            {
//                b.totalFare = value as? String ?? "0"
//            }
//            self.saveTripSummey(data: data,booking: b )
//        }
//
//        b.isRated = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.IsRated] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.IsRated] as! Bool : false
//
//        b.paymentMethod = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.PaymentMethod] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.PaymentMethod] as? String : ""
//        b.lastFourDigits = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.LastFourDigits] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.LastFourDigits] as? String : ""
//
//        b.trackId = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TrackId] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TrackId] as! String : ""
//
//        b.tripType = (!self.isNsnullOrNil(object:booking[Constants.BookingResponseAPIKey.TripType] as AnyObject)) ? booking[Constants.BookingResponseAPIKey.TripType] as! Int16 : 1
//
//        return b
//    }
//
//    func saveTripSummey(data: [AnyHashable: Any], booking: KTBooking) {
//        for keyvalue in booking.toKeyValueBody! {
//            (keyvalue as! KTKeyValue).mr_deleteEntity()
//        }
//        booking.toKeyValueBody = NSOrderedSet()
//
//        if let value = data["Body"]
//        {
//            KTBaseFareEstimateManager().saveKeyValueBody(keyValue: value as! [[AnyHashable : Any]], tariff: booking as KTBaseTrariff)
//        }
//
//        for keyvalue in booking.toKeyValueHeader! {
//            (keyvalue as! KTKeyValue).mr_deleteEntity()
//        }
//        booking.toKeyValueHeader = NSOrderedSet()
//        KTBaseFareEstimateManager().saveKeyValueHeader(keyValue: data["Header"] as! [[AnyHashable : Any]], tariff: booking as KTBaseTrariff)
//    }
//
//    func pendingBookings() -> [KTBooking] {
//
//        var bookings : [KTBooking] = []
//        let predicate : NSPredicate = NSPredicate(format:"bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d OR bookingStatus == %d",BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue)
//
//        bookings = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking]
//
//        return bookings
//    }
//
//    func historyBookings() -> [KTBooking] {
//        var bookings : [KTBooking] = []
//        let predicate : NSPredicate = NSPredicate(format:"bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d AND bookingStatus != %d" , BookingStatus.PENDING.rawValue,BookingStatus.DISPATCHING.rawValue,BookingStatus.CONFIRMED.rawValue, BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue,BookingStatus.UNKNOWN.rawValue)
//
//        bookings = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTBooking]
//
//        return bookings
//    }
//
//    func getBooking(bookingId id : String) -> KTBooking
//    {
//        var booking : KTBooking
//        let predicate : NSPredicate = NSPredicate(format:"bookingId != %d" , id)
//
////        booking = KTBooking.mr_findAllSorted(by: "pickupTime", ascending: false, with: predicate, in: NSManagedObjectContext.mr_default()) as! KTBooking
//        booking = KTBooking.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())!
//
//        return booking
//    }
//
//    //MARK: - Booking Sync Time
//    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
////    func bookingSyncTime() -> String {
////        var syncDate = UserDefaults.standard.object(forKey: BOOKING_SYNC_TIME) as? Date
////        if syncDate == nil {
////            syncDate = self.defaultSyncDate()
////        }
////        let syncTimeInterval: TimeInterval = (syncDate?.timeIntervalSince1970)!
////        let strSyncTimeInterval = String(format: "%.0f", syncTimeInterval)
////        return strSyncTimeInterval
////    }
////
////    func updateBookingSyncTime() {
////        let defaults: UserDefaults? = UserDefaults.standard
////        defaults?.set(Date(), forKey: BOOKING_SYNC_TIME)
////        defaults?.synchronize()
////    }
////
////    func removeSyncTime() {
////        let defaults: UserDefaults? = UserDefaults.standard
////        defaults?.removeObject(forKey: BOOKING_SYNC_TIME)
////        defaults?.synchronize()
////    }
////
////    func defaultSyncDate() -> Date? {
////        return Date(timeIntervalSince1970: 0)
////        //Default date of 1970
////    }
//
//    func booking(forBookingID bookingId: String, completion completionBlock:@escaping KTDALCompletionBlock) {
//        booking(bookingId, false, completion: completionBlock)
//    }
//
//    func booking(_ id: String, _ isBookingId: Bool, completion completionBlock:@escaping KTDALCompletionBlock) {
//        let url = (isBookingId ? Constants.APIURL.Booking : Constants.APIURL.Track) + "/" + id
//        self.get(url: url, param: nil, completion: completionBlock) { (response, cBlock) in
//            let booking : KTBooking = self.saveBookingInDB(booking: response as [AnyHashable : Any])
//
//            cBlock(Constants.APIResponseStatus.SUCCESS, [Constants.ResponseAPIKey.Data: booking])
//        }
//    }
}
