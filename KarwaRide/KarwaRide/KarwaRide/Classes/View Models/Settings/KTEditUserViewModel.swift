//
//  KTEditUserViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTEditUserViewModelDelegate {
    func reloadTable()
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
        var phone = ""
        var countryCode = "+974"
        
        if user != nil && user?.phone != nil {
            phone = (user?.phone)!
        }
        
        if user != nil && user?.countryCode != nil {
            countryCode = (user?.countryCode)!
        }
        
        return countryCode + phone
    }
    
    func emailVerified() -> Bool {
        var verified = false
        if user != nil {
            verified = user!.isEmailVerified
        }
        return verified
    }

//    if(user.email == null || user.email.isEmpty())
//    tv.setText(R.string.enter_email_msg);
//    else if(!user.isEmailVerfied)
//    tv.setText(R.string.send_email_msg);
//    else if(user.isEmailVerfied)
//    {
//    tv.setTextColor(view.getContext().getResources().getColor(R.color.green));
//    tv.setText(R.string.email_verified);
//    }
    func emailMessage() -> String
    {
        var message = "enter_email_msg".localized()

        if user != nil && user!.email != nil && !(user!.email!.isEmpty)
        {
            if(user?.isEmailVerified ?? false)
            {
                message = "email_verified".localized()
            }
            else
            {
                message = "send_email_msg".localized()
            }
        }
        return message
    }
    
    func resendVisible() -> Bool
    {
        var shouldVisible = false
        
        if user != nil && user!.email != nil && !(user!.email!.isEmpty)
        {
            if(!(user?.isEmailVerified ?? false))
            {
                shouldVisible = true
            }
        }
        return shouldVisible
    }
    
    func userDOB() -> String
    {
        var dob :String = "dd mmm yyyy"
        if user != nil && user?.dob != nil
        {
            dob = user?.dob?.getUIFormatDate() ?? "dd mmm yyyy"
        }
        return dob
    }
    
    func userDOBObject() -> Date {
        var dob : Date = Date(timeIntervalSinceReferenceDate: 0)
        if user != nil && user?.dob != nil{
            dob = user?.dob! ?? Date(timeIntervalSinceReferenceDate: 0)
        }
        return dob
    }
    
    func userGender() -> String {
        var gender :String = "gender_array[0]".localized()
        if user != nil {
            switch user?.gender
            {
            case 1:
                gender = "gender_array[1]".localized()
                break
            case 2:
                gender = "gender_array[2]".localized()
                break
            default:
                gender = "gender_array[0]".localized()
                break
            }
        }
        return gender
    }
    
    func updateName(userName: String)
    {
        updateProfile(userName: userName, userEmail: "", dob: nil, gen: user!.gender, shouldValidate: false)
    }
    
    func updateEmail(email: String)
    {
        updateProfile(userName: "", userEmail: email, dob: nil, gen: user!.gender, shouldValidate: true)
    }
    
    func updateGender(gender: Int16)
    {
        updateProfile(userName: "", userEmail: "", dob: nil, gen: gender, shouldValidate: false)
    }

    func updateDOB(dob: Date)
    {
        updateProfile(userName: "", userEmail: "", dob: dob, gen: user!.gender, shouldValidate: false)
    }

    func updateProfile(userName : String?, userEmail : String?, dob: Date?, gen: Int16, shouldValidate: Bool)
    {
        var error = ""
        if(shouldValidate)
        {
            error = validate(userName: userName, userEmail: userEmail)
        }

        if  error.isEmpty
        {
            delegate?.showProgressHud(show: true, status: "account_info_title".localized())
            
            KTUserManager().updateUserInfo(
                name: userName!,
                email: (userEmail != nil && !userEmail!.isEmpty) ? userEmail! : "",
                dob: dob?.getServerFormatDate() ?? "",
                gender: gen,
                completion: { (status, response) in
                    self.delegate?.hideProgressHud()
                    self.reloadData()
                    if status == Constants.APIResponseStatus.SUCCESS {
                        (self.delegate as! KTEditUserViewModelDelegate).showSuccessAltAndMoveBack()
                    }
                    else {
                        
                        self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                    }
            })
        }
        else {
            self.delegate?.showError!(title: "error_sr".localized() , message: error)
        }
    }
    
    func resendEmail()
    {
        delegate?.showProgressHud(show: true, status: "str_resend".localized())
        
        KTUserManager().resendEmail(completion: { (status, response) in
            
            self.delegate?.hideProgressHud()
            
            if status == Constants.APIResponseStatus.SUCCESS
            {
                self.delegate?.showSuccessBanner("", "send_email_msg".localized())
            }
            else
            {
                self.delegate?.showPopupMessage(response["T"] as! String, response["M"] as! String)
            }
        })
    }
    
    func reloadData()
    {
        user = loginUserInfo()
        (self.delegate as! KTEditUserViewModelDelegate).reloadTable()
    }
    
    func validate(userName : String?, userEmail : String?) -> String {
        var errorString :String = ""
        if userEmail == nil || userEmail == "" || userEmail?.isEmail == false {
            errorString = "err_no_email".localized()
        }
        return errorString
    }
}
