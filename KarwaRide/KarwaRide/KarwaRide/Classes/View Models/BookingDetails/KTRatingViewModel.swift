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
    func showAltForThanks(rating: Int32)
    func enableSubmitButton()
    func showConsolationText()
    func showConsolationText(message: String)
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
        if rating == 4
        {
            del?.showConsolationText(message: "Overall good experience, impress with service. But need some improvements")
        }
        else if rating == 5
        {
            del?.showConsolationText(message: "Overall good experience. Impress with service")
        }
        else
        {
            del?.showConsolationText(message: "We're really sorry. Tell us what happened?")
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
    
    func isComplainable(atIndex idx: Int) -> Bool {
        var isComplainable : Bool = false
        if idx < (reasons?.count)!
        {
            isComplainable = reasons![idx].isComplainable
        }
        return isComplainable
    }
    
    func selectedReasonIds() -> [Int16] {
        var rreasonsIdx : [Int16] = []
        for r in (del?.selectedIdx())! {
            rreasonsIdx.append(reasons![r.intValue].reasonCode)
        }
        return rreasonsIdx
    }
    
    func btnRattingTapped()
    {
        let rating = (del?.userFinalRating())!
        if (rating > 3) || (rating != 0 && selectedReasonIds().count != 0)
        {
            rateBooking()
        }
        else
        {
            delegate?.showToast(message: "Please select rating for driver")
        }
    }
    
    func rateBooking() {
        let reasonIds : [Int16] = selectedReasonIds()
        let rating : Int32 = (del?.userFinalRating())!
        let bookingId : String = (booking?.bookingId)!
        let tripType : Int16 = (booking?.tripType)!
        
        self.delegate?.showProgressHud(show: true, status: "Updating Driver Rating")
        KTRatingManager().rateBooking(forId: bookingId, rating: rating, reasons: reasonIds, tripType: tripType) { (status, response) in
            self.delegate?.hideProgressHud()
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.booking?.isRated = true
                KTNotificationManager().deleteNotification(forBooking: self.booking!)
                KTDALManager().saveInDb()
                self.del?.showAltForThanks(rating: rating)
                
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
    
    //MARK:- Rate Applicaiton
    func rateApplication() {
        
        // App Store URL.
        let appStoreLink = "https://itunes.apple.com/us/app/karwa-ride/id1050410517?mt=8"
        
        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                if success {
                    print("Launching \(url) was successful")
                    AnalyticsUtil.trackBehavior(event: "Rate-App")
                }})
        }
    }
}
