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
    func navigateToEnterEmail(phone: String, password: String, maskedEmail: String)
}

class KTForgotPassViewModel: KTBaseViewModel {
    //weak var delegate: KTForgotPassViewModelDelegate?
    var phone : String?
    var password: String?
    var rePassword: String?
    
    struct ForgotPassValidationError {
        
        let NoPassword = "Password is mandatory"
        let NoRePassword = "Confirm Password is mandatory"
        let PasswordNotMatch = "Password & confirm password don't match"
        let NoPhone = "Mobile number is mandatory"
        let WrongPhone = "Please enter valid mobile number"
        let PasswordSixChar = "Password should be more than six charecter"
    }
    
//    init(del: Any) {
//        super.init()
//        delegate = del as? KTForgotPassViewModelDelegate
//    }
    
    func btnSubmitTapped() ->Void
    {
        phone = (delegate as! KTForgotPassViewModelDelegate).phoneNumber()
        password = (delegate as! KTForgotPassViewModelDelegate).password()
        rePassword = (delegate as! KTForgotPassViewModelDelegate).rePassword()
        let error = validate()
        if error.count == 0
        {
            delegate?.showProgressHud(show: true, status: "Retriving your password")
            KTUserManager.init().sendForgotPassRequest(phone: phone!, password: (password?.md5())!, completion: { (status, response) in
                
                self.delegate?.showProgressHud(show: false)
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    (self.delegate as! KTForgotPassViewModelDelegate).navigateToOTP()
                }
                else if(status == Constants.APIResponseStatus.VALIDATE_EMAIL)
                {
                    var responseDic = response as! [String : Any]
                    responseDic = (responseDic[Constants.ResponseAPIKey.Data] as? [String : Any])!
                    
                    let maskedEmail = responseDic[Constants.LoginResponseAPIKey.MaskedEmail] as? String
                    
                    (self.delegate as! KTForgotPassViewModelDelegate).navigateToEnterEmail(phone: self.phone!, password: (self.password?.md5())!, maskedEmail: maskedEmail!)
                }
                else
                {
                    (self.delegate as! KTForgotPassViewModelDelegate).showError!(title: response["T"] as! String, message: response["M"] as! String)
                }
            })
        }
        else
        {
            (delegate as! KTForgotPassViewModelDelegate).showError!(title: "Error", message: error)
        }
        
    }
    
    func validate() -> String {
        var error : String = ""
        if !KTUtils.isObjectNotNil(object: phone! as AnyObject) || phone!.count == 0
        {
            error = ForgotPassValidationError().NoPhone
        }
        else if !(phone?.isPhoneNumber)!
        {
            error = ForgotPassValidationError().WrongPhone
        }
        
        else if !KTUtils.isObjectNotNil(object: password as AnyObject) || password?.count == 0
        {
            error = ForgotPassValidationError().NoPassword
        }
        else if !KTUtils.isObjectNotNil(object: rePassword as AnyObject) || rePassword?.count == 0
        {
            error = ForgotPassValidationError().NoRePassword
        }
        else if (password != rePassword)
        {
            error = ForgotPassValidationError().PasswordNotMatch
        }
        else if (password?.count)! < 6
        {
            error = ForgotPassValidationError().PasswordSixChar
        }
        return error
    }
}
