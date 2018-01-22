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

    weak var delegate: KTLoginViewModelDelegate?
    
    init(del: Any) {
        super.init()
        delegate = del as? KTLoginViewModelDelegate
    }
    
    func loginBtnTapped()
    {
        let phone : String = (delegate?.phoneNumber())!
        let password: String = "5df74bed761f1a361415b14c68839eac"//(delegate?.Password())!
        
        //delegate.model
        KTUserManager.init().login(phone: phone, password:password ) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS
            {
                self.delegate?.navigateToBooking()
            }
            else if(status == Constants.APIResponseStatus.UNVERIFIED)
            {
                self.delegate?.navigateToOTP()
            }
            else
            {
                self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
}
