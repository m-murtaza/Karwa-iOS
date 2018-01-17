//
//  KTForgotPassViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTForgotPassViewModelDelegate: KTViewModelDelegate {
    func phoneNumber() -> String?
    func password() -> String?
    func rePassword() -> String?

    func navigateToOTP()
}

class KTForgotPassViewModel: KTBaseViewModel {
    weak var delegate: KTForgotPassViewModelDelegate?
    var phone : String?
    var password: String?
    var rePassword: String?
    
    struct ForgotPassValidationError {
        
        let NoPassword = "Password is mandatory"
        let NoRePassword = "Confirm Password is mandatory"
        let PasswordNotMatch = "Password & confirm password don't batch"
        let NoPhone = "Mobile number is mandatory"
        let WrongPhone = "Please enter valid mobile number"
    }
    
    init(del: Any) {
        super.init()
        delegate = del as? KTForgotPassViewModelDelegate
    }
    
    func btnSubmitTapped() ->Void
    {
        phone = self.delegate!.phoneNumber()
        password = self.delegate!.password()
        rePassword = self.delegate!.rePassword()
        let error = validate()
        if error.count == 0
        {
            KTUserManager.init().sendForgotPassRequest(phone: phone!, password: "5df74bed761f1a361415b14c68839eac", completion: { (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    
                    self.delegate?.navigateToOTP()
                }
                else
                {
                    self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
                }
            })
        }
        else
        {
            self.delegate?.showError!(title: "Error", message: error)
        }
        
    }
    
    func validate() -> String {
        var error : String = ""
        if !KTUtils.isObjectNotNil(object: phone! as AnyObject) || phone!.count == 0
        {
            error = ForgotPassValidationError.init().NoPhone
        }
        else if !(phone?.isPhoneNumber)!
        {
            error = ForgotPassValidationError.init().WrongPhone
        }
        
        else if !KTUtils.isObjectNotNil(object: password as AnyObject) || password?.count == 0
        {
            error = ForgotPassValidationError.init().NoPassword
        }
        else if !KTUtils.isObjectNotNil(object: rePassword as AnyObject) || rePassword?.count == 0
        {
            error = ForgotPassValidationError.init().NoRePassword
        }
        else if (password != rePassword)
        {
            error = ForgotPassValidationError.init().PasswordNotMatch
        }
        return error
    }
}
