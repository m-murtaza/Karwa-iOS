//
//  KTBookingDetailsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

protocol KTBookingDetailsViewModelDelegate: KTViewModelDelegate {
    func initializeMap(location : CLLocationCoordinate2D)
    func showCurrentLocationDot(show: Bool)
    func showVTrackMarker(vTrack: VehicleTrack)
    func updateBookingCard()
    //func estimatedFare()
    
    func updateAssignmentInfo()
}

class KTBookingDetailsViewModel: KTBaseViewModel {

    var booking : KTBooking?
    var del : KTBookingDetailsViewModelDelegate?
    override func viewDidLoad() {
        del = self.delegate as? KTBookingDetailsViewModelDelegate
        initializeViewWRTBookingStatus()
    }
    
    func initializeViewWRTBookingStatus() {
    
        //Check for booking == nil
        guard let _ = booking else {
            return
        }
        
        updateMap()
        updateBookingCard()
        updateAssignmentInfo()
    }
    
    //MARK:- Driver Info
    func callDriver() {
        guard let phone : String = booking?.driverPhone else {
            del?.showError!(title: "Error", message: "Driver phone number is not available")
            return
        }
        if !phone.isEmpty {
            UIApplication.shared.open(URL(string: "TEL://\(phone)")!)
        }
        else {
            del?.showError!(title: "Error", message: "Driver phone number is not available")
        }
        
    }
    
    func updateAssignmentInfo() {
        if booking?.driverName != nil && !(booking?.driverName?.isEmpty)! {
            del?.updateAssignmentInfo()
        }
        
    }
    
    func driverName() -> String {
        
        guard let name = booking?.driverName else {
            return ""
        }
        
        return name
    }
    
    func vehicleNumber() -> String {
        guard var vNum = booking?.vehicleNo else {
            return ""
        }
        
        let vNumArr = vNum.components(separatedBy: " ")
        if vNumArr.count >= 2 {
            
            vNum = vNumArr[1]
        }
        
        return vNum
    }
    
    func imgForPlate() -> UIImage {
        
        guard let vehicleType = booking?.vehicleType else {
            return UIImage(named:"taxiplate")!
        }
        if KTVehicleTypeManager.isTaxi(vType: VehicleType(rawValue: vehicleType)!) {
            return UIImage(named:"taxiplate")!
        }
        return UIImage(named:"limo_number_plate")!
    }
    
    func driverRating() -> Double {
        
        guard let rating = booking?.driverRating else {
            return 0.0
        }
        return rating
    }
    //MARK:- BookingCard
    func updateBookingCard() {
        del?.updateBookingCard()
        
    }
    
    func pickMessage () -> String {
        return  "(\((booking?.pickupMessage!)!))"
    }
    
    func pickAddress() -> String{
    
        return  (booking?.pickupAddress!)!
    }
    
    func dropAddress() -> String{
        var dropAdd : String?
        
            
        dropAdd = booking?.dropOffAddress
        if dropAdd == nil || (dropAdd?.isEmpty)! {
            
            dropAdd = ""
        }
        
        return dropAdd!
    }
    
    func cellBGColor() -> UIColor{
        var color : UIColor = UIColor.white
            
        switch booking?.bookingStatus {
        case BookingStatus.CONFIRMED.rawValue?,  BookingStatus.ARRIVED.rawValue?,BookingStatus.PICKUP.rawValue?:
                color = UIColor(hexString:"#F9FDFC")
                
        case BookingStatus.PENDING.rawValue?, BookingStatus.DISPATCHING.rawValue? :
                color = UIColor(hexString:"#E5F5F2")
                
        case BookingStatus.COMPLETED.rawValue?:
                color = UIColor(hexString:"#D7E6E3")
                
            case BookingStatus.CANCELLED.rawValue?, BookingStatus.TAXI_NOT_FOUND.rawValue? ,BookingStatus.TAXI_UNAVAIALBE.rawValue? ,BookingStatus.NO_TAXI_ACCEPTED.rawValue?, BookingStatus.EXCEPTION.rawValue?:
                color = UIColor(hexString:"#FEE5E5")
                
            default:
                color = UIColor(hexString:"#F9FDFC")
            }
        
        return color
    }
    
    func cellBorderColor() -> UIColor{
        var color : UIColor = UIColor.white
            switch booking?.bookingStatus {
            case BookingStatus.CONFIRMED.rawValue?,  BookingStatus.ARRIVED.rawValue?,BookingStatus.PICKUP.rawValue?,BookingStatus.PENDING.rawValue?, BookingStatus.DISPATCHING.rawValue?, BookingStatus.COMPLETED.rawValue? :
                color = UIColor(hexString:"#CFD0D1")
                
            case BookingStatus.CANCELLED.rawValue?, BookingStatus.TAXI_NOT_FOUND.rawValue? ,BookingStatus.TAXI_UNAVAIALBE.rawValue? ,BookingStatus.NO_TAXI_ACCEPTED.rawValue?, BookingStatus.EXCEPTION.rawValue?:
                color = UIColor(hexString:"#EBC0C6")
                
            default:
                color = UIColor(hexString:"#CFD0D1")
            }
    
        return color
    }
    
    func pickupDateOfMonth() -> String{
        
            return (booking!.pickupTime! as NSDate).dayOfMonth()
    }
    
    func pickupMonth() -> String{
        
        return (booking!.pickupTime! as NSDate).threeLetterMonth()
        
    }
    
    func pickupYear() -> String{
        
        return (booking!.pickupTime! as NSDate).year()
        
    }
    
    func pickupDayAndTime() -> String{
        
        let day = (booking!.pickupTime! as NSDate).dayOfWeek()
        let time = (booking!.pickupTime! as NSDate).timeWithAMPM()
        
        let dayAndTime = "\(day), \(time)"
        
        return dayAndTime
    }
    
    func vehicleType() -> String {
        
        var type : String = ""
        switch booking!.vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAiportTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue,VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "TAXI"
            
        case VehicleType.KTStandardLimo.rawValue:
            type = "STANDARD"
            
        case VehicleType.KTBusinessLimo.rawValue:
            type = "Business"
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "Luxury"
        default:
            type = ""
        }
        return type
    }
    
    func bookingStatusImage() -> UIImage? {
        
        var imgName : String?
        var img : UIImage?
        switch booking!.bookingStatus {
            
        case BookingStatus.COMPLETED.rawValue:
            imgName = "MyTripsCompleted"
        case BookingStatus.ARRIVED.rawValue:
            imgName = "MyTripsArrived"
        case BookingStatus.CONFIRMED.rawValue:
            imgName = "MyTripsAssigned"
        case BookingStatus.CANCELLED.rawValue:
            imgName = "MyTripsCancelled"
        case BookingStatus.PENDING.rawValue, BookingStatus.DISPATCHING.rawValue:
            imgName = "MyTripsScheduled"
        case BookingStatus.TAXI_NOT_FOUND.rawValue, BookingStatus.TAXI_UNAVAIALBE.rawValue, BookingStatus.NO_TAXI_ACCEPTED.rawValue:
            imgName = "MyTripNoRideFound"
        default:
            print("Do nothing")
            
        }
        if imgName != nil && !(imgName?.isEmpty)! {
            img = UIImage(named:imgName!)
        }
        
        return img
    }
    
    func estimatedFare() -> String {
        return booking!.estimatedFare!
    }
    
    
    //MARK:- Map
    
    
    func updateMap() {
        
        del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        del?.showCurrentLocationDot(show: true)
        
        switch booking?.bookingStatus {
        case BookingStatus.ARRIVED.rawValue?, BookingStatus.CONFIRMED.rawValue?:
            fetchTaxiForTracking()
        default:
            print("Defaul case")
        }
        
    }
    
    func fetchTaxiForTracking() {
        KTBookingManager().trackVechicle(jobId: (booking?.bookingId)!,vehicleNumber: (booking?.vehicleNo)!, completion: {
            (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                let vtrack : VehicleTrack = self.parseVehicleTrack(track: response)
                self.del?.showVTrackMarker(vTrack: vtrack)
            }
        })
    }
    
    func parseVehicleTrack(track rtrack : [AnyHashable:Any]) -> VehicleTrack {
        
        let track : VehicleTrack = VehicleTrack()
        //track.vehicleNo = rtrack["VehicleNo"] as! String
        track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
        //track.vehicleType = rtrack["VehicleType"] as! Int
        track.bearing = rtrack["Bearing"] as! Float
        track.trackType = VehicleTrackType.vehicle
        return track
    }
    
    func imgForTrackMarker() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
            case VehicleType.KTAiportTaxi.rawValue?, VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?,VehicleType.KTSpecialNeedTaxi.rawValue?,VehicleType.KTAiport7Seater.rawValue? :
                img = UIImage(named:"BookingMapTaxiIco")
        
            case VehicleType.KTStandardLimo.rawValue?:
                    img = UIImage(named: "BookingMapStandardIco")
            case VehicleType.KTBusinessLimo.rawValue?:
                img = UIImage(named: "BookingMapBusinessIco")
            
            case VehicleType.KTLuxuryLimo.rawValue?:
                img = UIImage(named: "BookingMapLuxuryIco")
            default:
                img = UIImage(named:"BookingMapTaxiIco")
        }
        return img!
    }
    
}
