//
//  KTMasedEmailConfirmationViewModel.swift
//  KarwaRide
//
//  Created by Irfan Muhammed on 5/20/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

protocol KTMaskedEmailViewModelDelegate: KTViewModelDelegate {

    func phoneNumber() -> String?
    func email() -> String?
    func md5password() -> String?
    func countryCallingCode() -> String?
    func navigateToOTP()
}

class KTMasedEmailConfirmationViewModel: KTBaseViewModel {
 
    var email: String = ""
    
    func btnSubmitTapped() ->Void
    {
        let phone = (delegate as! KTMaskedEmailViewModelDelegate).phoneNumber()
        let countryCode = (delegate as! KTMaskedEmailViewModelDelegate).countryCallingCode()
        email = (delegate as! KTMaskedEmailViewModelDelegate).email()!
        let password = (delegate as! KTMaskedEmailViewModelDelegate).md5password()

        let error = validate()
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_retrieving_your_password".localized())
            KTUserManager.init().sendForgotPassRequest(countryCode: countryCode!,phone: phone!, password: (password?.md5())!, email: email, completion: { (status, response) in
                
                self.delegate?.showProgressHud(show: false)
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    (self.delegate as! KTMaskedEmailViewModelDelegate).navigateToOTP()
                }
                else
                {
//                    (self.delegate as! KTMaskedEmailViewModelDelegate).showError!(title: response["T"] as! String, message: response["M"] as! String)
                    (self.delegate as! KTMaskedEmailViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                                  message: response["M"] as! String)
                }
            })
        }
        else
        {
          (delegate as! KTMaskedEmailViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                   message: error)
        }
        
    }
    
    func validate() -> String {
        var errorString : String = ""
        if email == "" || email.isEmail == false {
            errorString = "err_no_email".localized()
        }
        return errorString
    }
}
