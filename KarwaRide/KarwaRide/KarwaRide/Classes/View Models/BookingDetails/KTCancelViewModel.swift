//
//  KTCancelViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/5/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTCancelViewModelDelegate : KTViewModelDelegate {
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
        super.viewDidLoad()
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
        if selectedIdx < 0 {
            self.delegate?.showError!(title: "error_sr".localized(), message: "txt_select_two_or_more".localized())
        }
        else {
            delegate?.showProgressHud(show: true, status: "please_dialog_msg_cancel_booking".localized())
            let reason : KTCancelReason = reasons[selectedIdx]
            KTCancelBookingManager().cancelBooking(bookingId: (del?.getBookingID())!, reasonId: Int(reason.reasonCode)) { (status, response) in
                
                self.delegate?.hideProgressHud()
                if status == Constants.APIResponseStatus.SUCCESS {
                    self.del?.cancelSuccess()
                }
                else {
                    self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as? String ?? "Error", message: response[Constants.ResponseAPIKey.Message] as? String ?? "Error")
                }
            }
        }
    }
    
}
