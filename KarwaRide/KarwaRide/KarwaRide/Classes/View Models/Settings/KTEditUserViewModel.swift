//
//  KTEditUserViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTEditUserViewModelDelegate {
    func showSuccessAltAndMoveBack()
}

class KTEditUserViewModel: KTBaseViewModel {

    private var user : KTUser?
    
    override func viewDidLoad() {
        user = loginUserInfo()
    }
    
    func loginUserInfo() -> KTUser {
        return KTUserManager().loginUserInfo()!
    }
    
    func userName() -> String {
        var name :String = ""
        if user != nil {
            
            name = (user?.name)!
        }
        return name
    }
    
    func userEmail() -> String {
        var email :String = ""
        if user != nil {
            
            if user?.email != nil {
                
                email = (user?.email)!
            }
        }
        return email
    }
    
    func userPhone() -> String {
        var phone :String = ""
        if user != nil {
            
            phone = (user?.phone)!
        }
        return phone
    }
    
    func btnSaveTapped(userName : String?, userEmail : String?) {
        let error = validate(userName: userName, userEmail: userEmail)
        if  error == nil {
            //No error
            delegate?.showProgressHud(show: true, status: "Updating Account Info")
            KTUserManager().updateUserInfo(name: userName!, email: (userEmail != nil) ? userEmail! : "", completion: { (status, response) in
                self.delegate?.hideProgressHud()
                if status == Constants.APIResponseStatus.SUCCESS {
                    (self.delegate as! KTEditUserViewModelDelegate).showSuccessAltAndMoveBack()
                }
                else {
                    
                    self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                }
            })
        }
        else {
            self.delegate?.showError!(title: "Error" , message: error!)
        }
    }
    
    func validate(userName : String?, userEmail : String?) -> String? {
        var errorString :String?
        if userName == nil || userName == "" {
            errorString = "Please enter your name"
        }
        return errorString
    }
}
