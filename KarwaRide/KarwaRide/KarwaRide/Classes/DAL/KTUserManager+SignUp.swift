//
//  KTUserManager+SignUp.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

extension KTUserManager
{
    
    func signUp(name: String, mobileNo:String,email:String,password:String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        let param : [AnyHashable: Any] = [Constants.SignUpParams.Name : name,
                                           Constants.SignUpParams.Phone : mobileNo,
                                           Constants.SignUpParams.Email : email,
                                           Constants.SignUpParams.Password: password]
        
        self.post(url: Constants.APIURL.SignUp, param: param as! [String : Any], completion: completionBlock) { (response, cBlock) in
            
            cBlock(Constants.APIResponseStatus.SUCCESS , response)
        }
    }
    
    func varifyOTP(phone:String,code:String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        let params : NSMutableDictionary = [Constants.LoginParams.Phone : phone,
                                            Constants.LoginParams.OTP:code ]
        self.login(params: params,url:Constants.APIURL.Otp, completion: completionBlock)
        
    }
    
    
    func resendOTP(phone:String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {

        let url = Constants.APIURL.ResendOtp + "/" + phone
        
        self.get(url: url, param: nil, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
}
