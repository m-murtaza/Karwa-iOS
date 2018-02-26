//
//  KTOTPViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTOTPViewModelDelegate: KTViewModelDelegate {
    func OTPCode() -> String?
    func phoneNum() -> String?
    
    func navigateToBooking()
}

class KTOTPViewModel: KTBaseViewModel {
    
    //weak var delegate: KTOTPViewModelDelegate?
    
    
    
//    init(del: Any) {
//        super.init()
//        delegate = del as? KTOTPViewModelDelegate
//    }
    
    func confirmCode() -> Void {
        
        let otp : String? = ((self.delegate as! KTOTPViewModelDelegate).OTPCode())!
        let phone : String = ((self.delegate as! KTOTPViewModelDelegate).phoneNum())!
        if KTUtils.isObjectNotNil(object: otp as AnyObject)
        {
            KTUserManager.init().VarifyOTP(phone: phone, code: otp!
                , completion: { (status, response) in
                    
                    if status == Constants.APIResponseStatus.SUCCESS
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.UserLogin), object: nil)
                        (self.delegate as! KTOTPViewModelDelegate).navigateToBooking()
                    }
                    else
                    {
                        self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
                    }
            })
        }
    }
}
