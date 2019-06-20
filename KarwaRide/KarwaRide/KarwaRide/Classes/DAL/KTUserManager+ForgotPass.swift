//
//  KTUserManager+ForgotPass.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

extension KTUserManager
{
    func sendForgotPassRequest(countryCode: String, phone: String, password: String,completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String : Any] = [Constants.UpdatePassParam.Phone : phone,
                                      Constants.LoginParams.CountryCode : countryCode,
                                           Constants.UpdatePassParam.Password: password]
        
        self.post(url: Constants.APIURL.ForgotPass, param: param, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
        
    }
    
    func sendForgotPassRequest(countryCode: String, phone: String, password: String, email: String, completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String : Any] = [Constants.UpdatePassParam.Phone : phone,
                                      Constants.LoginParams.CountryCode : countryCode,
                                      Constants.UpdatePassParam.Password: password,
                                      Constants.EditAccountInfoParam.Email: email]
        
        self.post(url: Constants.APIURL.ForgotPass, param: param, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
        
    }
}
