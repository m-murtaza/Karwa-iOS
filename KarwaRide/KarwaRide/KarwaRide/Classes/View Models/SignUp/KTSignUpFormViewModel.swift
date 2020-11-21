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
    let NoName = "err_name".localized()
    let NoPassword = "err_no_password".localized()
    let PasswordSixChar = "err_min_password".localized()
    let NoPhone = "err_no_phone".localized()
    let WrongPhone = "err_no_phone".localized()
    let WrongEmail = "err_no_email".localized()
  }
    
//    init(del: Any) {
//        super.init()
//        delegate = del as? KTSignUpViewModelDelegate
//    }
    
    var country = Country(countryCode: "QA", phoneExtension: "974")
    func setSelectedCountry(country: Country) {
        self.country = country
    }

    func SignUp() -> Void {
        name = (self.delegate as! KTSignUpViewModelDelegate).name()
        mobileNo = (self.delegate as! KTSignUpViewModelDelegate).mobileNo()
        password = (self.delegate as! KTSignUpViewModelDelegate).password()
        email = (self.delegate as! KTSignUpViewModelDelegate).email()
        let error = validate()
        
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_signing_up".localized())
            KTUserManager.init().signUp(name: name!, countryCode: "+" + country.phoneExtension, mobileNo: mobileNo!, email: email!, password: password!.md5(), completion: { (status, response) in
                self.delegate?.showProgressHud(show: false)
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
          (self.delegate as! KTSignUpViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                   message: error)
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
        else if !(mobileNo?.isPhoneValid(region: country.countryCode))!
        {
            error = SignUpValidationError.init().WrongPhone
        }
        else if  !(email?.isEmpty)! &&  !(email?.isEmail)!
        {
            //email is option field
            error = SignUpValidationError.init().WrongEmail
        }
        else if !KTUtils.isObjectNotNil(object: password as AnyObject) || password?.count == 0
        {
            error = SignUpValidationError().NoPassword
        }
        else if (password?.count)! < Constants.MIN_PASSWORD_LENGTH
        {
            error = SignUpValidationError().PasswordSixChar
        }
        return error
    }
}
