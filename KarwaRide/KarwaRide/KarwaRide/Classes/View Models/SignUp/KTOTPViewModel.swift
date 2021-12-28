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
    func navigateToChallengeVerificationScreen(maskedString: String, challengeType: String)
    func getCountryCode() -> String
    func getOtpType() -> String?
}

extension KTOTPViewModelDelegate {
    func navigateToChallengeVerificationScreen() {
        
    }
}

class KTOTPViewModel: KTBaseViewModel {
    

    func getChallenge(countryCode: String, phone:String) {
        KTUserManager().getChallenge(countryCode: countryCode, phone: phone, completion: { (status, response) in
            print("challenge response", response)
            if let challengeType = response["ChallengeType"] as? String {
                if challengeType == "Name" || challengeType == "Email" {
                    if let challenge = response["Challenge"] as? String {
                        (self.delegate as! KTOTPViewModelDelegate).navigateToChallengeVerificationScreen(maskedString: challenge, challengeType: challengeType)
                    }
                } else {
                    if let challenge = response["Challenge"] as? String {
                        (self.delegate as! KTOTPViewModelDelegate).navigateToChallengeVerificationScreen(maskedString: challenge, challengeType: challengeType)
                    }
                }
                
            }
        })
    }
    
    func confirmCode() {
        if(((self.delegate as! KTOTPViewModelDelegate).OTPCode()) != nil) {
            let otp : String? = ((self.delegate as! KTOTPViewModelDelegate).OTPCode())!
            let countryCode : String = ((self.delegate as! KTOTPViewModelDelegate).countryCallingCode())!
            let phone : String = ((self.delegate as! KTOTPViewModelDelegate).phoneNum())!
            let otpType = ((self.delegate as! KTOTPViewModelDelegate).getOtpType())!
            if KTUtils.isObjectNotNil(object: otp as AnyObject)
            {
                delegate?.showProgressHud(show: true, status: "str_confirming_code".localized())
                KTUserManager().varifyOTP(countryCode: countryCode, phone: phone, code: otp!, otpType: otpType
                                          , completion: { (status, response) in
                    
                    print("************ response otp **********", response)
                    
                    self.delegate?.showProgressHud(show: false)
                    
                    if let challenge = response["OtpOperationStatus"] as? String, challenge == "ASK_TO_SOLVE_CHALLENGE"{
                        self.getChallenge(countryCode: countryCode, phone: phone)
                    } else {
                        if status == Constants.APIResponseStatus.SUCCESS {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.UserLogin), object: nil)
                            (self.delegate as! KTOTPViewModelDelegate).navigateToBooking()
                        } else {
                            self.delegate?.showError!(title: "", message: response["M"] as! String)
                        }
                    }
                    
                })
            }
        }
        else
        {
            self.delegate?.showError!(title: "error_sr".localized(),
                                      message: "Please Enter Code first")
        }
    }
    
    func resendOTP() {
        
        let phone : String = ((self.delegate as! KTOTPViewModelDelegate).phoneNum())!
        delegate?.showProgressHud(show: true, status: "Resending OTP")
        KTUserManager().resendOTP(countryCode: (self.delegate as! KTOTPViewModelDelegate).getCountryCode(), phone: phone, otpType: (self.delegate as! KTOTPViewModelDelegate).getOtpType() ?? "") { (status, response) in
            
            self.delegate?.hideProgressHud()
            if status == Constants.APIResponseStatus.SUCCESS {
            
                self.delegate?.showError!(title: "error_sr".localized(),
                                          message: "Verification code sent")
            }
            else
            {
                self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
}
