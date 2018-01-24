//
//  KTSignUpFormViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTSignUpViewModelDelegate: KTViewModelDelegate {
    func name() -> String?
    func mobileNo() -> String?
    func email() -> String?
    func password() -> String?
    
    func navigateToOTP()
}

class KTSignUpFormViewModel: KTBaseViewModel {

    var name: String?
    var mobileNo: String?
    var email: String?
    var password: String?
    
    //weak var delegate: KTSignUpViewModelDelegate?

    struct SignUpValidationError {
        let NoName = "Name is mandatory"
        let NoPassword = "Password is mandatory"
        let PasswordSixChar = "Password should be more then six charecter"
        let NoPhone = "Mobile number is mandatory"
        let WrongPhone = "Please enter valid mobile number"
        let WrongEmail = "Please enter valid email address"
    }
    
//    init(del: Any) {
//        super.init()
//        delegate = del as? KTSignUpViewModelDelegate
//    }
    
    func SignUp() -> Void {
        name = (self.delegate as! KTSignUpViewModelDelegate).name()
        mobileNo = (self.delegate as! KTSignUpViewModelDelegate).mobileNo()
        password = (self.delegate as! KTSignUpViewModelDelegate).password()
        email = (self.delegate as! KTSignUpViewModelDelegate).email()
        let error = validate()
        
        if error.count == 0
        {
            KTUserManager.init().signUp(name: name!, mobileNo: mobileNo!, email: email!, password: password!, completion: { (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    (self.delegate as! KTSignUpViewModelDelegate).navigateToOTP()
                }
                else
                {
                    (self.delegate as! KTSignUpViewModelDelegate).showError!(title: response["T"] as! String, message: response["M"] as! String)
                }
            })
        }
        else
        {
            //self.delegate?.navigateToOTP()
            (self.delegate as! KTSignUpViewModelDelegate).showError!(title: "Error", message: error)
        }
    }
    
    func validate() -> String {
        var error : String = ""
        if !KTUtils.isObjectNotNil(object: name! as AnyObject) || name!.count == 0
        {
            error = SignUpValidationError.init().NoName
        }
        else if !KTUtils.isObjectNotNil(object: mobileNo! as AnyObject) || mobileNo!.count == 0
        {
            error = SignUpValidationError.init().NoPhone
        }
        else if !(mobileNo?.isPhoneNumber)!
        {
            error = SignUpValidationError.init().WrongPhone
        }
        else if  (email?.isEmail)!
        {
            error = SignUpValidationError.init().WrongEmail
        }
        else if !KTUtils.isObjectNotNil(object: password as AnyObject) || password?.count == 0
        {
            error = SignUpValidationError.init().NoPassword
        }
        else if (password?.count)! < 6
        {
            error = SignUpValidationError.init().PasswordSixChar
        }
        return error
    }
}
