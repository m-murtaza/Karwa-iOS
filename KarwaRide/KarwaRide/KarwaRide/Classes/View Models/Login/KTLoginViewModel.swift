//
//  KSLoginViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

protocol KTLoginViewModelDelegate: KTViewModelDelegate {
    func phoneNumber() -> String
    func password() -> String
    
    func navigateToBooking()
    func navigateToOTP()
}

class KTLoginViewModel: KTBaseViewModel {

    //weak var delegate: KTLoginViewModelDelegate?
    
//    init(del: Any) {
//        super.init()
//        delegate = del as? KTLoginViewModelDelegate
//    }
    
    struct LoginValidationError {
      let NoName = "err_name".localized()
      let NoPassword = "err_no_password".localized()
      let PasswordSixChar = "err_min_password".localized()
      let NoPhone = "err_no_phone".localized()
      let WrongPhone = "err_no_phone".localized()
    }

    var country = Country(countryCode: "QA", phoneExtension: "974")
    func setSelectedCountry(country: Country) {
        self.country = country
    }

    func loginBtnTapped()
    {
        var phone : String = ((delegate as! KTLoginViewModelDelegate).phoneNumber())
        let password: String = (delegate as! KTLoginViewModelDelegate).password().md5()
        
        if country.phoneExtension == "\(phone.extractCountryCode())" {
            phone = phone.components(separatedBy: "\(phone.extractCountryCode())")[1]
        }
        
        let error = validate(phoneNumber: phone, password: password)
        
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_logging_in".localized())
            KTUserManager.init().login(countryCodey: "+" + country.phoneExtension, phone: phone, password:password ) { (status, response) in
                self.delegate?.showProgressHud(show: false)
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.UserLogin), object: nil)
                    (self.delegate as! KTLoginViewModelDelegate).navigateToBooking()
                }
                else if(status == Constants.APIResponseStatus.UNVERIFIED)
                {
                    (self.delegate as! KTLoginViewModelDelegate).navigateToOTP()
                }
                else
                {
                    (self.delegate as! KTLoginViewModelDelegate).showError!(title: response["T"] as! String, message: response["M"] as! String)
                }
            }
        }
        else
        {
            (self.delegate as! KTLoginViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                    message: error)
        }
    }
    
    func validate(phoneNumber: String, password: String) -> String {
        var error : String = ""
        if !(phoneNumber.isPhoneValid(region: country.countryCode))
        {
            error = LoginValidationError.init().WrongPhone
        }
        else if !KTUtils.isObjectNotNil(object: password as AnyObject) || password.count == 0
        {
            error = LoginValidationError().NoPassword
        }
        else if (password.count) < Constants.MIN_PASSWORD_LENGTH
        {
            error = LoginValidationError().PasswordSixChar
        }
        return error
    }
}
