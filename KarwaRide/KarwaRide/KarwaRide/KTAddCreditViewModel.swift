//
//  KTAddCreditViewModel.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 07/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

protocol KTAddCreditViewModelDelegate: KTViewModelDelegate {
    func addCard() -> String
}

class KTAddCreditViewModel: KTBaseViewModel {

    var del : KTAddCreditViewModelDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        del = self.delegate as? KTAddCreditViewModelDelegate
        
        KTUserManager.init().isUserLogin { (login:Bool) in
            if login == true
            {
//                self.fetchBooking((self.del?.getTrackTripId())!, false)
            }
            else
            {
                (UIApplication.shared.delegate as! AppDelegate).showLogin()
            }
        }
    }
    
    @objc func addCard() {
        self.del?.showProgressHud(show: true, status: "Fetching Trip Information")

        //TODO: Show expired link here
        
//        KTBookingManager().booking(bookingId as String, isFromBookingId) { (status, response) in
//
//                self.del?.hideProgressHud()
//
//                if status == Constants.APIResponseStatus.SUCCESS
//                {
//                    let updatedBooking : KTBooking = response[Constants.ResponseAPIKey.Data] as! KTBooking
////                    self.bookingUpdateTriggered(updatedBooking)
////                    self.del?.showDriverInfoBox()
//                }
//                else
//                {
//                    self.del?.showErrorBanner("   ", response["M"] as! String)
//
//                }
//        }
    }
    
}
