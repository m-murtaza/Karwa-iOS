//
//  KTChangePasswordViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTChangePasswordViewModelDelegate {
    func showSuccessAltAndMoveBack()
}

class KTChangePasswordViewModel: KTBaseViewModel {

    func btnChangePasswordTapped(oldPassword: String?, password: String?, rePassword: String?) {
        
        let error: String = validate(oldPassword: oldPassword,password: password,rePassword: rePassword)
        if error.isEmpty {
            delegate?.showProgressHud(show: true, status: "Updating Password")
            KTUserManager().updatePassword(oldPassword: oldPassword!.md5(), password: password!.md5(), completion: { (status, response) in
                self.delegate?.hideProgressHud()
                if status == Constants.APIResponseStatus.SUCCESS {
                    (self.delegate as! KTChangePasswordViewModelDelegate).showSuccessAltAndMoveBack()
                }
                else {
                    
                    self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                }
            })
        }
        else {
            self.delegate?.showError!(title: "Error", message: error)
            
        }
    }
    
    func validate(oldPassword: String?, password: String?, rePassword: String?) -> String {
        
        var error : String = ""
        if oldPassword == nil  || (oldPassword?.isEmpty)! {
            error = "Old password is mandatory"
        }
        else if password == nil  || (password?.isEmpty)! {
            error = "Password is mandatory"
        }
        else if password != rePassword {
            error = "Passwords do not match"
        }
        return error
    }
}
