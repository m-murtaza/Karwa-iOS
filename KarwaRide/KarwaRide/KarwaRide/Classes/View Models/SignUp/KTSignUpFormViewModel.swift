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
    
    func navigateToBooking()
    func showError(title:String, message:String)
    
}

class KTSignUpFormViewModel: KTBaseViewModel {

    var name: String?
    var mobileNo: String?
    var email: String?
    var password: String?
    
    weak var delegate: KTSignUpViewModelDelegate?

    struct SignUpValidationError {
        let NoName = "Name is mandatory"
        let NoPassword = "Password is mandatory"
        let NoPhone = "Mobile number is mandatory"
        let WrongPhone = "Please enter valid mobile number"
        let WrongEmail = "Please enter valid email address"
    }
    
    init(del: Any) {
        super.init()
        delegate = del as? KTSignUpViewModelDelegate
    }
    
    func SignUp() -> Void {
        name = self.delegate?.name()
        mobileNo = self.delegate?.mobileNo()
        password = self.delegate?.password()
        email = self.delegate?.email()
        if validate().count > 0
        {
            KTUserManager.init().signUp(name: name!, mobileNo: mobileNo!, email: email!, password: password!, completion: { (status, response) in
                
            })
            
        }
    }
    
    func validate() -> String {
        var error : String = ""
        if !KTUtils.isObjectNotNil(object: name! as AnyObject) && name!.count == 0
        {
            error = SignUpValidationError.init().NoName
            
        }
        
        return error
    }
}
