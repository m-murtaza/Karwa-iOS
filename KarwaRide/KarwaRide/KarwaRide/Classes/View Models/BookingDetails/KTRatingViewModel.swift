//
//  KTRatingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTRatingViewModelDelegate : KTViewModelDelegate {
    
    func closeScreen()
    func updateDriverImage(url: URL)
    func updateDriver(name: String)
    func updateDriver(rating: Double)
    func hideSystemRating()
    func updateTrip(fare: String)
    func updatePickup(date: String)
    func removeAllTags()
    func addTag(tag: String)
    func selectedIdx() -> [NSNumber]
    func userFinalRating() -> Int32
    func showAltForThanks()
    func enableSubmitButton()
    func showConsolationText()
    func hideConsolationText()
}

class KTRatingViewModel: KTBaseViewModel {

    var del : KTRatingViewModelDelegate?
    var booking : KTBooking?
    var reasons : [KTRatingReasons]?
    
    override func viewDidLoad() {
        del = self.delegate as? KTRatingViewModelDelegate
        super.viewDidLoad()
        //fetchReason(forRating: 3)
        
        //updateDriverImage()
    }
    
    func setBookingForRating(booking b : KTBooking)  {
        booking = b
        updateView()
        //updateDriverImage()
    }
    
    func ratingUpdate(rating: Double) {
        del?.enableSubmitButton()
        if rating == 4 {
            del?.showConsolationText()
        }
        else {
            del?.hideConsolationText()
        }
        fetchReason(forRating: Int32(rating))
    }
    
    private func fetchReason(forRating rating: Int32) {
        reasons = KTRatingManager().ratingsReason(forRating: rating, language: "EN")!
        
        del?.removeAllTags()
        for reason in reasons! {
            del?.addTag(tag: reason.desc!)
            //print(reason.desc ?? "")
        }
    }
    
    func reason(atIndex idx: Int) -> String {
        var r : String = ""
        if idx < (reasons?.count)! {
            r = reasons![idx].desc!
        }
        return r
    }
    
    func selectedReasonIds() -> [Int16] {
        var rreasonsIdx : [Int16] = []
        for r in (del?.selectedIdx())! {
            rreasonsIdx.append(reasons![r.intValue].reasonCode)
        }
        return rreasonsIdx
    }
    
    func btnRattingTapped()  {
        if (del?.userFinalRating())! != 0 {
            rateBooking()
        }
        else {
            delegate?.showError!(title: "Error", message: "Please select rating for driver")
        }
    }
    
    func rateBooking() {
        let reasonIds : [Int16] = selectedReasonIds()
        let rating : Int32 = (del?.userFinalRating())!
        let bookingId : String = (booking?.bookingId)!
        
        self.delegate?.showProgressHud(show: true, status: "Updating Driver Rating")
        KTRatingManager().rateBooking(forId: bookingId, rating: rating, reasons: reasonIds) { (status, response) in
            self.delegate?.hideProgressHud()
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.booking?.isRated = true
                KTNotificationManager().deleteNotification(forBooking: self.booking!)
                KTDALManager().saveInDb()
                self.del?.showAltForThanks()
                
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                self.del?.closeScreen()
            }
            
        }
    }
    
    func updateView(){
        updateDriverImage()
        del?.updateDriver(name: (booking?.driverName)!)
        if booking?.driverRating == 0.0 {
            del?.hideSystemRating()
        }
        else {
            del?.updateDriver(rating: (booking?.driverRating)!)
        }
        del?.updateTrip(fare: (booking?.fare)!)
        del?.updatePickup(date: formatedDateForRating(date: (booking?.pickupTime)!))
        //let formatedDate = formatedDateForRating(date: (booking?.pickupTime)!)
    }
    func formatedDateForRating(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM, YYYY 'at' HH:mm a"
         return dateFormatter.string(from: date)
    
    }
    //MARK:- Driver Image
    func updateDriverImage() {
        guard (booking != nil), ((booking?.driverId) != nil) else {
            return
        }
        
        let baseURL = KTConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey)
        let url = URL(string: baseURL + Constants.APIURL.DriverImage + "/" + (booking?.driverId)!)!
        del?.updateDriverImage(url: url)
    }
}
