//
//  KTUserManager+SignUp.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Alamofire

extension KTUserManager
{
    
    func signUp(name: String, countryCode: String, mobileNo:String,email:String,password:String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        let param : [AnyHashable: Any] = [Constants.SignUpParams.Name : name,
                                           Constants.LoginParams.CountryCode : countryCode,
                                           Constants.SignUpParams.Phone : mobileNo,
                                           Constants.SignUpParams.Email : email,
                                           Constants.SignUpParams.Password: password]
        
        self.post(url: Constants.APIURL.SignUp, param: param as! [String : Any], completion: completionBlock) { (response, cBlock) in
            
            cBlock(Constants.APIResponseStatus.SUCCESS , response)
        }
    }
    
    func varifyOTP(countryCode: String, phone:String, code:String, otpType:String, completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        let params: Parameters = [Constants.LoginParams.Phone : phone,
                                            Constants.LoginParams.CountryCode : countryCode,
                                            Constants.LoginParams.OTP:code,
                                            Constants.LoginParams.OtpType: otpType]
        
        self.post(url: Constants.APIURL.Otp, param: params, completion: completionBlock, success: {
            (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        })
        
    }
    
    func getChallenge(countryCode: String, phone:String, completion completionBlock:@escaping KTDALCompletionBlock) {
        let param : [AnyHashable: Any] = [Constants.LoginParams.Phone : phone,
                                          Constants.LoginParams.CountryCode : countryCode]
        self.post(url: Constants.APIURL.GetChallenge, param: param as! [String : Any], completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS,response)
        }
    }
    
    func resendOTP(countryCode: String, phone:String, otpType: String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        
        if otpType != "" {
            let param : [AnyHashable: Any] = [Constants.LoginParams.Phone : phone,
                                              Constants.LoginParams.CountryCode : countryCode,
                                              Constants.LoginParams.OtpType: otpType]
            self.post(url: Constants.APIURL.ResendOtp, param: param as! [String : Any], completion: completionBlock) { (response, cBlock) in
                cBlock(Constants.APIResponseStatus.SUCCESS,response)
            }
        } else {
            let param : [AnyHashable: Any] = [Constants.LoginParams.Phone : phone,
                                              Constants.LoginParams.CountryCode : countryCode]
            self.post(url: Constants.APIURL.ResendOtp, param: param as! [String : Any], completion: completionBlock) { (response, cBlock) in
                cBlock(Constants.APIResponseStatus.SUCCESS,response)
            }
        }
        
        
    }
    
}
