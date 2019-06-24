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
    func countryCallingCode() -> String?
    func navigateToBooking()
    func getCountryCode() -> String
}

class KTOTPViewModel: KTBaseViewModel {
    
    func confirmCode() {
        if(((self.delegate as! KTOTPViewModelDelegate).OTPCode()) != nil)
        {
            let otp : String? = ((self.delegate as! KTOTPViewModelDelegate).OTPCode())!
            let countryCode : String = ((self.delegate as! KTOTPViewModelDelegate).countryCallingCode())!
            let phone : String = ((self.delegate as! KTOTPViewModelDelegate).phoneNum())!
            if KTUtils.isObjectNotNil(object: otp as AnyObject)
            {
                delegate?.showProgressHud(show: true, status: "Confirming Code")
                KTUserManager().varifyOTP(countryCode: "+" + countryCode, phone: phone, code: otp!
                    , completion: { (status, response) in
                        self.delegate?.showProgressHud(show: false)
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
        else
        {
            self.delegate?.showError!(title: "", message: "Please Enter Code first")
        }
    }
    
    func resendOTP() {
        
        let phone : String = ((self.delegate as! KTOTPViewModelDelegate).phoneNum())!
        delegate?.showProgressHud(show: true, status: "Resending OTP")
        KTUserManager().resendOTP(countryCode: "+" + (self.delegate as! KTOTPViewModelDelegate).countryCode(), phone: phone) { (status, response) in
            
            self.delegate?.hideProgressHud()
            if status == Constants.APIResponseStatus.SUCCESS {
            
                self.delegate?.showError!(title: "", message: "Verification code sent")
            }
            else
            {
                self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
}
