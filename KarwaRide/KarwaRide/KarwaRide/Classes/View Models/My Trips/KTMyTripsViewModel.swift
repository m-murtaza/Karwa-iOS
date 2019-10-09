//
//  KTMyTripsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTMyTripsViewModelDelegate {
    func reloadTable()
    func showNoBooking()
    func moveToDetails()
    func endRefreshing()
}

class KTMyTripsViewModel: KTBaseViewModel {
    
    private var bookings : [KTBooking]?
    public var selectedBooking : KTBooking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchBookings()
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        fetchBookings()
        if(selectedBooking != nil && selectedBooking?.bookingType == 1)
        {
            showBooking(selectedBooking!)
            selectedBooking = nil;
        }
    }
    
    func fetchBookings()  {
        delegate?.showProgressHud(show: true)
        KTBookingManager().syncBookings { (status, response) in
            //if status == Constants.APIResponseStatus.SUCCESS {
                
            self.fetchBookingsFromDB()
            self.delegate?.hideProgressHud()

            if  self.bookings != nil && (self.bookings?.count)! > 0 {
            
                (self.delegate as! KTMyTripsViewModelDelegate).reloadTable()
            }
            else {
                (self.delegate as! KTMyTripsViewModelDelegate).showNoBooking()
            }
            
            (self.delegate as! KTMyTripsViewModelDelegate).endRefreshing()
        }
    }
    private func fetchBookingsFromDB() {
        
        let pendingBooking : [KTBooking] = KTBookingManager().pendingBookings()
        let historyBooking : [KTBooking] = KTBookingManager().historyBookings()
        bookings = pendingBooking + historyBooking
//        for b in bookings! {
//            print((b as KTBooking).callerId)
//        }
    }
    
    
    func numberOfRows() -> Int {
        
        var numRows : Int = 0
        if bookings != nil {
            numRows = (bookings?.count)!
        }
        return numRows
    }
    
    func showBooking(_ booking:KTBooking) {
        
        selectedBooking = booking;
        (self.delegate as! KTMyTripsViewModelDelegate).moveToDetails()
    }
    
    //MARK:- Table Data
    
    func rowSelected(forIdx idx:Int) {
        
        if bookings != nil && idx < (bookings?.count)! {
            
            selectedBooking = bookings![idx] as KTBooking
        }
        (self.delegate as! KTMyTripsViewModelDelegate).moveToDetails()
    }
    
    func pickAddress(forIdx idx: Int) -> String{
        var pickAdd : String = ""
        if bookings != nil && idx < (bookings?.count)! {
            
            pickAdd = (bookings![idx] as KTBooking).pickupAddress!
        }
        return pickAdd
    }
    
    func dropAddress(forIdx idx: Int) -> String{
        var dropAdd : String?
        if bookings != nil && idx < (bookings?.count)! {
            
            dropAdd = (bookings![idx] as KTBooking).dropOffAddress
            if dropAdd == nil || (dropAdd?.isEmpty)! {
                
                dropAdd = "No Destination Set"
            }
        }
        return dropAdd!
    }
    
    func callerId(forIdx idx: Int) -> String{
        var cId : String = ""
        if bookings != nil && idx < (bookings?.count)! {
            
            cId = (bookings![idx] as KTBooking).callerId!
        }
        return cId
    }
    func showCallerID() -> Bool {
        return KTAppSessionInfo.currentSession.customerType == CustomerType.CORPORATE
    }
    
    func cellBGColor(forIdx idx: Int) -> UIColor{
        var color : UIColor = UIColor.white
        if bookings != nil && idx < (bookings?.count)! {
            
            switch (bookings![idx] as KTBooking).bookingStatus {
            case BookingStatus.CONFIRMED.rawValue,  BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue:
                color = UIColor(hexString:"#F9FDFC")
            
            case BookingStatus.PENDING.rawValue, BookingStatus.DISPATCHING.rawValue :
                color = UIColor(hexString:"#E5F5F2")
                
            case BookingStatus.COMPLETED.rawValue:
                color = UIColor(hexString:"#D7E6E3")
                
            case BookingStatus.CANCELLED.rawValue, BookingStatus.TAXI_NOT_FOUND.rawValue ,BookingStatus.TAXI_UNAVAIALBE.rawValue ,BookingStatus.NO_TAXI_ACCEPTED.rawValue, BookingStatus.EXCEPTION.rawValue:
                color = UIColor(hexString:"#FEE5E5")
                
            default:
                color = UIColor(hexString:"#F9FDFC")
            }
            
            //pickAdd = (bookings![idx] as KTBooking).bookingStatus!
        }
        return color
    }
    
    func cellBorderColor(forIdx idx: Int) -> UIColor{
        var color : UIColor = UIColor.white
        if bookings != nil && idx < (bookings?.count)! {
            
            switch (bookings![idx] as KTBooking).bookingStatus {
            case BookingStatus.CONFIRMED.rawValue,  BookingStatus.ARRIVED.rawValue,BookingStatus.PICKUP.rawValue,BookingStatus.PENDING.rawValue, BookingStatus.DISPATCHING.rawValue, BookingStatus.COMPLETED.rawValue :
                color = UIColor(hexString:"#CFD0D1")
                
            case BookingStatus.CANCELLED.rawValue, BookingStatus.TAXI_NOT_FOUND.rawValue ,BookingStatus.TAXI_UNAVAIALBE.rawValue ,BookingStatus.NO_TAXI_ACCEPTED.rawValue, BookingStatus.EXCEPTION.rawValue:
                color = UIColor(hexString:"#EBC0C6")
                
            default:
                color = UIColor(hexString:"#CFD0D1")
            }
        }
        return color
    }
    
    func pickupDateOfMonth(forIdx idx: Int) -> String{
        
        var dateOfMonth : String = ""
        if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
            
            dateOfMonth = (bookings![idx] as KTBooking).pickupTime!.dayOfMonth()
        }
        return dateOfMonth
    }
    
    func pickupMonth(forIdx idx: Int) -> String{
        
        var month : String = ""
        if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
            
            month = (bookings![idx] as KTBooking).pickupTime!.threeLetterMonth()
        }
        return month
    }
    
    func pickupYear(forIdx idx: Int) -> String{
        
        var year : String = ""
        if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
            
            year = (bookings![idx] as KTBooking).pickupTime!.year()
        }
        return year
    }
    
    func pickupDayAndTime(forIdx idx: Int) -> String{
        
        var dayAndTime : String = ""
        if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
            
            let day = (bookings![idx] as KTBooking).pickupTime!.dayOfWeek()
            let time = (bookings![idx] as KTBooking).pickupTime!.timeWithAMPM()
            
            dayAndTime = "\(day), \(time)"
        }
        return dayAndTime
    }
    
    func vehicleType(forIdx idx: Int) -> String {
        
        var type : String = ""
        switch (bookings![idx] as KTBooking).vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue:
            type = "TAXI"
        
        case VehicleType.KTCityTaxi7Seater.rawValue:
            type = "7 SEATER"
        
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "A.TAXI"

        case VehicleType.KTStandardLimo.rawValue:
            type = "STANDARD"
        
        case VehicleType.KTBusinessLimo.rawValue:
            type = "BUSINESS"
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "LUXURY"
        default:
            type = ""
        }
        return type
    }
    
    func bookingStatusImage(forIdx idx: Int) -> UIImage? {
        
        var imgName : String?
        var img : UIImage?
        switch (bookings![idx] as KTBooking).bookingStatus {
        
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
        case BookingStatus.PICKUP.rawValue:
//            img = UIImage.gifImageWithName("MyTripHired")
            imgName = "MyTripsHired"
        default:
            img = UIImage()
            print("Do nothing")
            
        }
        if imgName != nil && !(imgName?.isEmpty)! {
            img = UIImage(named:imgName!)
        }
        
        return img
    }
 
    // Triggered only when BookingDetails Controller is in focus
    func bookingUpdateTriggered(_ updatedBooking: KTBooking)
    {
        fetchBookings()
    }
}
