//
//  KTRatingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import StoreKit

protocol KTRatingViewModelDelegate : KTViewModelDelegate {
    
    func closeScreen(_ rating : Int32)
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
    func showSelectReasonText(message: String)
    func hideConsolationText()
    func setTitleBtnSubmit(label: String)
    func showHideComplainableLabel(show: Bool)
    func resetComplainComment()
    func updatePickUpAddress(address: String)
    func updateDropAddress(address: String)
}

class KTRatingViewModel: KTBaseViewModel {

    var del : KTRatingViewModelDelegate?
    var booking : KTBooking?
    var reasons : [KTRatingReasons]?
    var remarks = ""

    override func viewDidLoad() {
        del = self.delegate as? KTRatingViewModelDelegate
        super.viewDidLoad()
        //fetchReason(forRating: 3)
        
        //updateDriverImage()
    }
    
    override func viewDidAppear() {
        del = self.delegate as? KTRatingViewModelDelegate
        updateView()
    }
    
    func setBookingForRating(booking b : KTBooking)  {
        booking = b
        
        //updateDriverImage()
    }
    
    func ratingUpdate(rating: Double) {
        del?.enableSubmitButton()
        if rating == 4
        {
            del?.showConsolationText(message: "rating_msg_satisfied".localized())
            del?.showSelectReasonText(message: "")
        }
        else if rating == 5
        {
            del?.showConsolationText(message: "rating_msg_completely_satisfied".localized())
            del?.showSelectReasonText(message: "")
        } else if rating ==  3
        {
            del?.showSelectReasonText(message: "")
        }
        else
        {
            del?.showSelectReasonText(message: "txt_select_two_or_more".localized())
            del?.showConsolationText(message: "rating_msg_no_satisfied".localized())
        }

        del?.setTitleBtnSubmit(label: "str_submit_upper".localized())
        del?.showHideComplainableLabel(show: false)
        del?.resetComplainComment()
        remarks = ""

        fetchReason(forRating: Int32(rating))
    }
    
    func saveComment(_ comment: String)
    {
        remarks = comment
    }
    
    func removeComment()
    {
        remarks = ""
    }
    
    private func fetchReason(forRating rating: Int32) {
        reasons = KTRatingManager().ratingsReason(forRating: rating, language: Device.getLanguage())!
        
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
    
    func selectedReasonIsComplainable() -> Bool
    {
        var isComplainableReasonSelected : Bool = false

        for r in (del?.selectedIdx())!
        {
            if(reasons![r.intValue].isComplainable)
            {
                isComplainableReasonSelected = true
                break
            }
        }

        return isComplainableReasonSelected
    }
    
    func tagViewTapped()
    {
        let complainableRating = selectedReasonIsComplainable()
        del?.setTitleBtnSubmit(label: complainableRating ? "str_submit_n_report".localized() : "str_submit_upper".localized())
        del?.showHideComplainableLabel(show: complainableRating)
        
        let rating = (del?.userFinalRating())!

        if selectedReasonIsComplainable() {
            
            if(rating >= 3){
                del?.showSelectReasonText(message:"")
            }
            
            del?.showSelectReasonText(message:complainableRating ? "txt_complain_reasons".localized() : "txt_select_two_or_more".localized())
        } else {
            
            if(rating < 3){
                if del?.selectedIdx().count == 0{
                    del?.showSelectReasonText(message:"txt_select_two_or_more".localized())
                } else {
                    del?.showSelectReasonText(message:"")
                }
            }
        }

    }
    
    func btnRattingTapped()
    {
        let rating = (del?.userFinalRating())!

        if(rating < 3 && selectedReasonIsComplainable())
        {
            if(remarks == "")
            {
                delegate?.showErrorBanner("", "err_empty_complain_remarks".localized())
            }
            else
            {
                rateBooking()
            }
        }
        else if (rating > 3) || (rating != 0 && selectedReasonIds().count != 0)
        {
            rateBooking()
        }
        else
        {
            delegate?.showErrorBanner("", "text_please_select".localized())
        }
    }
    
    func rateBooking() {
        let reasonIds : [Int16] = selectedReasonIds()
        let rating : Int32 = (del?.userFinalRating())!
        let bookingId : String = (booking?.bookingId)!
        let tripType : Int16 = (booking?.tripType)!
        
        self.delegate?.showProgressHud(show: true, status: "str_loading".localized())
        KTRatingManager().rateBooking(forId: bookingId, rating: rating, reasons: reasonIds, tripType: tripType, remarks: remarks) { (status, response) in
            self.delegate?.hideProgressHud()
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.booking?.isRated = true
                KTNotificationManager().deleteNotification(forBooking: self.booking!)
                KTDALManager().saveInDb()
                self.del?.showAltForThanks(rating: rating)
                
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                self.del?.closeScreen(-1)
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
        del?.updatePickUpAddress(address: booking?.pickupAddress ?? "")
        del?.updateDropAddress(address: booking?.dropOffAddress ?? "")
        //let formatedDate = formatedDateForRating(date: (booking?.pickupTime)!)
    }
    
    func vehicleType() -> String {
        
        var type : String = ""
        switch booking!.vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue:
            type = "txt_taxi".localized()
            
        case VehicleType.KTCityTaxi7Seater.rawValue:
            type = "txt_family_taxi".localized()
            
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "txt_accessible".localized()

        case VehicleType.KTStandardLimo.rawValue:
            type = "txt_limo_standard".localized()
            
        case VehicleType.KTBusinessLimo.rawValue:
            type = "txt_limo_buisness".localized()
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "txt_limo_luxury".localized()
        default:
            type = ""
        }
        return type
    }
    
    func paymentMethod() -> String
    {
        var paymentMethod = "Cash"
        let bookingStatus = bookingStatii()
        if(bookingStatus == BookingStatus.PICKUP.rawValue || bookingStatus == BookingStatus.ARRIVED.rawValue || bookingStatus == BookingStatus.CONFIRMED.rawValue || bookingStatus == BookingStatus.PENDING.rawValue || bookingStatus == BookingStatus.DISPATCHING.rawValue)
        {
            //Skipping the payment method because the booking hasn't been completed yet, so sticking to cash, it will be changed once we work for pre-paid payment
        }
        else if(!(booking!.lastFourDigits == "Cash" || booking!.lastFourDigits == "" || booking!.lastFourDigits == "CASH" || booking!.lastFourDigits == nil))
        {
            paymentMethod = "**** " +  booking!.lastFourDigits!
        }
        else if(booking!.paymentMethod == "ApplePay")
        {
            paymentMethod = "Paid by"
        }

        return paymentMethod
    }
    
    func bookingStatii() -> Int32 {
        return (booking?.bookingStatus)!
    }

    func paymentMethodIcon() -> String
    {
        var paymentMethodIcon = ""
        let bookingStatus = bookingStatii()
        if(bookingStatus == BookingStatus.PICKUP.rawValue || bookingStatus == BookingStatus.ARRIVED.rawValue || bookingStatus == BookingStatus.CONFIRMED.rawValue || bookingStatus == BookingStatus.PENDING.rawValue || bookingStatus == BookingStatus.DISPATCHING.rawValue)
        {
            //Skipping the payment method because the booking hasn't been completed yet, so sticking to cash, it will be changed once we work for pre-paid payment
        }
        else
        {
            paymentMethodIcon = booking!.paymentMethod ?? ""
        }
        return paymentMethodIcon
    }
    
    func getPassengerCountr() -> String
    {
        var passengerCount = "txt_four".localized()

        if(booking?.vehicleType == VehicleType.KTAiport7Seater.rawValue)
        {
            passengerCount = "txt_seven".localized()
        }
        
        return passengerCount
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
    
    func pickupDateOfMonth() -> String{
        
        return booking!.pickupTime!.dayOfMonth()
    }
    
    func pickupMonth() -> String{
        
        return " \(booking!.pickupTime!.threeLetterMonth()) "
        
    }
    
    func pickupYear() -> String{
        
        return booking!.pickupTime!.year()
        
    }
    
    func pickupDayAndTime() -> String{
        
        let day = booking!.pickupTime!.dayOfWeek()
        let time = booking!.pickupTime!.timeWithAMPM()
        
        let dayAndTime = "\(day), \(time) "
        
        return dayAndTime
    }
    
    //MARK:- Rate Applicaiton
    func rateApplication() {
        
        SKStoreReviewController.requestReview()
//        // App Store URL.
//        let appStoreLink = "https://itunes.apple.com/us/app/karwa-ride/id1050410517?mt=8"
//
//        /* First create a URL, then check whether there is an installed app that can
//         open it on the device. */
//        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
//            // Attempt to open the URL.
//            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
//                if success {
//                    print("Launching \(url) was successful")
//                    AnalyticsUtil.trackBehavior(event: "Rate-App")
//                }})
//        }
    }
}
