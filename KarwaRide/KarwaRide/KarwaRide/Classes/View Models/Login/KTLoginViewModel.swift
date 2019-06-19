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
    
    var country = Country(countryCode: "QA", phoneExtension: "974")
    func setSelectedCountry(country: Country) {
        self.country = country
    }

    func loginBtnTapped()
    {
        let phone : String = ((delegate as! KTLoginViewModelDelegate).phoneNumber())
        let password: String = (delegate as! KTLoginViewModelDelegate).password().md5()
        
        delegate?.showProgressHud(show: true, status: "Logging In")
        KTUserManager.init().login(countryCodey: country.phoneExtension, phone: phone, password:password ) { (status, response) in
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
}
