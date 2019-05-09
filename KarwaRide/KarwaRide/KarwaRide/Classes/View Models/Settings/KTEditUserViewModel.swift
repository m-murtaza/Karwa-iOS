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
        if user != nil && user!.name != nil{
            
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
    
    func userDOB() -> String {
        var dob :String = "dd mmm yyyy"
        if user != nil {
            
            dob = (user?.dob) ?? "dd mm yyyy"
        }
        return dob
    }
    
    func userGender() -> String {
        var gender :String = "Preder not to mention"
        if user != nil {
            switch user?.gender
            {
            case 1:
                gender = "Male"
                break
            case 2:
                gender = "Female"
                break
            default:
                gender = "Preder not to mention"
                break
            }
        }
        return gender
    }
    
    func btnSaveTapped(userName : String?, userEmail : String?, dob: String, gen: Int16) {
        let error = validate(userName: userName, userEmail: userEmail)
        if  error.isEmpty
        {
            delegate?.showProgressHud(show: true, status: "Updating Account Info")
            
            KTUserManager().updateUserInfo(
                name: userName!,
                email: (userEmail != nil) ? userEmail! : "",
                dob: dob,
                gender: gen,
                completion: { (status, response) in
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
            self.delegate?.showError!(title: "Error" , message: error)
        }
    }
    
    func validate(userName : String?, userEmail : String?) -> String {
        var errorString :String = ""
        if userName == nil || userName == "" {
            errorString = "Please enter your name"
        }
        if userEmail == nil || userEmail == "" || userEmail?.isEmail == false {
            errorString = "Please enter valid email address"
        }
        return errorString
    }
}
