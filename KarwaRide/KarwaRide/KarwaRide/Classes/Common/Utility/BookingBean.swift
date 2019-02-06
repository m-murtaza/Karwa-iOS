//
//  BookingBean.swift
//  KarwaRide
//
//  Created by Sam Ash on 2/6/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

class BookingBean
{
    var bookingId: String
    var bookingStatus: Int32
    var bookingType: Int16
    var callerId: String
    var cancelReason: Int32
    var creationTime: Date
    var driverId: String
    var driverName: String
    var driverPhone : String
    var driverRating: Double
    var dropOffAddress: String
    var dropOffLat: Double
    var dropOffLocationId: Int32
    var dropOffLon: Double
    var dropOffTime: Date
    var estimatedFare: String
    var eta: Int64
    var fare: String
    var isRated: Bool
    var lastFourDigits: String
    var paymentMethod: String
    var pickupAddress: String
    var pickupLat: Double
    var pickupLocationId: Int32
    var pickupLon: Double
    var pickupMessage: String
    var pickupTime: Date
    var serviceType: Int16
    var totalDistance: String
    var trackId: String
    var tripTrack: String
    var tripType: Int16
    var vehicleNo: String
    var vehicleType: Int16
    
    init(bookingEntity booking: KTBooking) {
        self.bookingId = booking.bookingId ?? ""
        self.bookingStatus = booking.bookingStatus
        self.bookingType = booking.bookingType
        self.callerId = booking.callerId ?? ""
        self.cancelReason = booking.cancelReason
        self.creationTime = booking.creationTime ?? Date()
        self.driverId = booking.driverId ?? ""
        self.driverName = booking.driverName ?? ""
        self.driverPhone = booking.driverPhone ?? ""
        self.driverRating = booking.driverRating
        self.dropOffAddress = booking.dropOffAddress ?? ""
        self.dropOffLat = booking.dropOffLat
        self.dropOffLocationId = booking.dropOffLocationId
        self.dropOffLon = booking.dropOffLon
        self.dropOffTime = booking.dropOffTime ?? Date()
        self.estimatedFare = booking.estimatedFare ?? ""
        self.eta = booking.eta
        self.fare = booking.fare ?? ""
        self.isRated = booking.isRated
        self.lastFourDigits = booking.lastFourDigits ?? ""
        self.paymentMethod = booking.paymentMethod ?? ""
        self.pickupAddress = booking.pickupAddress ?? ""
        self.pickupLat = booking.pickupLat
        self.pickupLocationId = booking.pickupLocationId
        self.pickupLon = booking.pickupLon
        self.pickupMessage = booking.pickupMessage ?? ""
        self.pickupTime = booking.pickupTime ?? Date()
        self.serviceType = booking.serviceType
        self.totalDistance = booking.totalDistance ?? ""
        self.trackId = booking.trackId ?? ""
        self.tripTrack = booking.tripTrack ?? ""
        self.tripType = booking.tripType
        self.vehicleNo = booking.vehicleNo ?? ""
        self.vehicleType = booking.vehicleType
    }
    
    init(_ bookingId: String,_ bookingStatus: Int32,_ bookingType: Int16,_ callerId: String,_ cancelReason: Int32,_ creationTime: Date,_ driverId: String,_ driverName: String,_ driverPhone : String,driverRating: Double,_ dropOffAddress: String,_ dropOffLat: Double,_ dropOffLocationId: Int32,_ dropOffLon: Double,_ dropOffTime: Date,_ estimatedFare: String,_ eta: Int64,_ fare: String,isRated: Bool,_ lastFourDigits: String,_ paymentMethod: String,_ pickupAddress: String,_ pickupLat: Double,_ pickupLocationId: Int32,_ pickupLon: Double,_ pickupMessage: String,_ pickupTime: Date,_ serviceType: Int16,_ totalDistance: String,_ trackId: String,_ tripTrack: String,_ tripType: Int16,_ vehicleNo: String,_ vehicleType: Int16){
        self.bookingId = bookingId
        self.bookingStatus = bookingStatus
        self.bookingType = bookingType
        self.callerId = callerId
        self.cancelReason = cancelReason
        self.creationTime = creationTime
        self.driverId = driverId
        self.driverName = driverName
        self.driverPhone = driverPhone
        self.driverRating = driverRating
        self.dropOffAddress = dropOffAddress
        self.dropOffLat = dropOffLat
        self.dropOffLocationId = dropOffLocationId
        self.dropOffLon = dropOffLon
        self.dropOffTime = dropOffTime
        self.estimatedFare = estimatedFare
        self.eta = eta
        self.fare = fare
        self.isRated = isRated
        self.lastFourDigits = lastFourDigits
        self.paymentMethod = paymentMethod
        self.pickupAddress = pickupAddress
        self.pickupLat = pickupLat
        self.pickupLocationId = pickupLocationId
        self.pickupLon = pickupLon
        self.pickupMessage = pickupMessage
        self.pickupTime = pickupTime
        self.serviceType = serviceType
        self.totalDistance = totalDistance
        self.trackId = trackId
        self.tripTrack = tripTrack
        self.tripType = tripType
        self.vehicleNo = vehicleNo
        self.vehicleType = vehicleType
    }
    
    static func getBookingEntityFromBooking(bookingBean booking: BookingBean) -> KTBooking
    {
        let bookingEntity : KTBooking = KTBookingManager().booking()
        
        bookingEntity.bookingId = booking.bookingId
        bookingEntity.bookingStatus = booking.bookingStatus
        bookingEntity.bookingType = booking.bookingType
        bookingEntity.callerId = booking.callerId
        bookingEntity.cancelReason = booking.cancelReason
        bookingEntity.creationTime = booking.creationTime
        bookingEntity.driverId = booking.driverId
        bookingEntity.driverName = booking.driverName
        bookingEntity.driverPhone = booking.driverPhone
        bookingEntity.driverRating = booking.driverRating
        bookingEntity.dropOffAddress = booking.dropOffAddress
        bookingEntity.dropOffLat = booking.dropOffLat
        bookingEntity.dropOffLocationId = booking.dropOffLocationId
        bookingEntity.dropOffLon = booking.dropOffLon
        bookingEntity.dropOffTime = booking.dropOffTime
        bookingEntity.estimatedFare = booking.estimatedFare
        bookingEntity.eta = booking.eta
        bookingEntity.fare = booking.fare
        bookingEntity.isRated = booking.isRated
        bookingEntity.lastFourDigits = booking.lastFourDigits
        bookingEntity.paymentMethod = booking.paymentMethod
        bookingEntity.pickupAddress = booking.pickupAddress
        bookingEntity.pickupLat = booking.pickupLat
        bookingEntity.pickupLocationId = booking.pickupLocationId
        bookingEntity.pickupLon = booking.pickupLon
        bookingEntity.pickupMessage = booking.pickupMessage
        bookingEntity.pickupTime = booking.pickupTime
        bookingEntity.serviceType = booking.serviceType
        bookingEntity.totalDistance = booking.totalDistance
        bookingEntity.trackId = booking.trackId
        bookingEntity.tripTrack = booking.tripTrack
        bookingEntity.tripType = booking.tripType
        bookingEntity.vehicleNo = booking.vehicleNo
        bookingEntity.vehicleType = booking.vehicleType
        
        return bookingEntity
    }
}
