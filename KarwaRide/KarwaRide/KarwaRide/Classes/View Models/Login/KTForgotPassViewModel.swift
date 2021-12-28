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
        
      let NoPassword = "err_min_password".localized()
      let NoRePassword = "err_min_confirm_password".localized()
      let PasswordNotMatch = "err_passwords_not_match".localized()
      let NoPhone = "err_no_phone".localized()
      let WrongPhone = "err_no_phone".localized()
      let PasswordSixChar = "err_min_password".localized()
    }
    
    var country = Country(countryCode: "QA", phoneExtension: "974")
    func setSelectedCountry(country: Country) {
        self.country = country
    }
    
    func btnSubmitTapped() ->Void
    {
        phone = (delegate as! KTForgotPassViewModelDelegate).phoneNumber()
        password = (delegate as! KTForgotPassViewModelDelegate).password()
        rePassword = (delegate as! KTForgotPassViewModelDelegate).rePassword()
        
        print(phone?.extractCountryCode ?? "")
                
        if country.phoneExtension == "\(phone?.extractCountryCode() ?? "")" {
            phone = phone?.components(separatedBy: "\(phone?.extractCountryCode() ?? "")")[1] ?? ""
        }
        
        let error = validate()
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_retrieving_your_password".localized())
            KTUserManager.init().sendForgotPassRequest(countryCode: "+" + country.phoneExtension, phone: phone!, password: (password?.md5())!, completion: { (status, response) in
                
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
                    (self.delegate as! KTForgotPassViewModelDelegate).showError!(title: response["T"] as? String ?? "error_sr".localized(), message: response["M"] as! String)
                }
            })
        }
        else
        {
            (delegate as! KTForgotPassViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                    message: error)
        }
        
    }
    
    func btnChangePhonenumberTapped() ->Void
    {
        phone = (delegate as! KTForgotPassViewModelDelegate).phoneNumber()
        
        print(phone?.extractCountryCode ?? "")
                
        if country.phoneExtension == "\(phone?.extractCountryCode() ?? "")" {
            phone = phone?.components(separatedBy: "\(phone?.extractCountryCode() ?? "")")[1] ?? ""
        }
        
        let error = validate()
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_loading".localized())
            
            KTUserManager().changePhoneNumber(param: ["CountryCode" : KTUserManager().loginUserInfo()?.countryCode ?? "", "phone": KTUserManager().loginUserInfo()?.phone ?? "", "NewPhone":  phone!, "NewCountryCode": "+" + country.phoneExtension], completion: { status, response in

                self.delegate?.showProgressHud(show: false)
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    (self.delegate as! KTForgotPassViewModelDelegate).navigateToOTP()
                }
                else
                {
                    (self.delegate as! KTForgotPassViewModelDelegate).showError!(title: response["T"] as? String ?? "error_sr".localized(), message: response["M"] as! String)
                }
            })
        }
        else
        {
            (delegate as! KTForgotPassViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                    message: error)
        }
        
    }
    
    func validate() -> String {
        var error : String = ""
        if !KTUtils.isObjectNotNil(object: phone! as AnyObject) || phone!.count == 0
        {
            error = ForgotPassValidationError().NoPhone
        }
        else if !(phone?.isPhoneValid(region: country.countryCode))!
        {
            error = ForgotPassValidationError().WrongPhone
        }
        return error
    }
}
