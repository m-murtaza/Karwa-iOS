//
//  KTCancelViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/5/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTCancelViewModelDelegate {
    func getBookingStatii() -> Int32
    func getBookingID() -> String
    func reloadTable()
    func cancelSuccess()
}

class KTCancelViewModel: KTBaseViewModel {

    var del : KTCancelViewModelDelegate?
    var reasons : [KTCancelReason] = []
    
    override func viewDidLoad() {
        del = self.delegate as? KTCancelViewModelDelegate
        fetchCancelReasons()
    }
    
    private func fetchCancelReasons() {
        
        reasons = KTCancelBookingManager().cancelReasons(forBookingStatii: (del?.getBookingStatii())!)
        del?.reloadTable()
    }
    
    func numberOfRows() -> Int {
        
        return reasons.count
    }
    
    func reasonTitle(idx : Int) -> String {
        return reasons[idx].desc!
    }
    
    func btnSubmitTapped(selectedIdx: Int) {
        
        let reason : KTCancelReason = reasons[selectedIdx]
        KTCancelBookingManager().cancelBooking(bookingId: (del?.getBookingID())!, reasonId: Int(reason.reasonCode)) { (status, response) in
            
            if status == Constants.APIResponseStatus.SUCCESS {
                self.del?.cancelSuccess()
            }
            else {
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
    }
    
}
