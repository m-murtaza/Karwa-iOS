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
}

class KTRatingViewModel: KTBaseViewModel {

    var del : KTRatingViewModelDelegate?
    var booking : KTBooking?
    
    override func viewDidLoad() {
        del = self.delegate as? KTRatingViewModelDelegate
        super.viewDidLoad()
        fetchReason(forRating: 3)
    }
    
    func fetchReason(forRating rating: Int32) {
        let reasons : [KTRatingReasons] = KTRatingManager().ratingsReason(forRating: rating, language: "EN")!
        
        for reason in reasons {
            
            print(reason.desc ?? "")
        }
    }
    
    func rateBooking() {
        let reasonIds : [Int16] = [1,3,4]
        let rating : Int32 = 3
        let bookingId : String = (booking?.bookingId)!
        
        
        KTRatingManager().rateBooking(forId: bookingId, rating: rating, reasons: reasonIds) { (status, response) in
            
            if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS {
                
                self.booking?.isRated = true
                KTDALManager().saveInDb()
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
        
    }
}
