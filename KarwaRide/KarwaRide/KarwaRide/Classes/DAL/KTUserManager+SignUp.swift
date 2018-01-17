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
        let param : NSMutableDictionary = [Constants.SignUpParams.Name : name,
                                           Constants.SignUpParams.Phone : mobileNo,
                                           Constants.SignUpParams.Email : email,
                                           Constants.SignUpParams.Password: password]
        KTWebClient.sharedInstance.post(uri: Constants.APIURL.SignUp, param: param as! [String : Any]) { (status, response) in
            if status != true
            {
                
                completionBlock(Constants.APIResponseStatus.FAILED_API,response)
            }
            else
            {
                if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS
                {
                    completionBlock(response[Constants.ResponseAPIKey.Status] as! String, response[Constants.ResponseAPIKey.Data] as! [AnyHashable : Any])
                }
                else
                {
                    completionBlock(response[Constants.ResponseAPIKey.Status] as! String,response[Constants.ResponseAPIKey.MessageDictionary] as! [AnyHashable:Any])
                }
            }
        }
    }
    
    func VarifyOTP(phone:String,code:String,completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        let params : NSMutableDictionary = [Constants.LoginParams.Phone : phone,
                                            Constants.LoginParams.OTP:code ]
        self.login(params: params,url:Constants.APIURL.Otp, completion: completionBlock)
        
        }
    
}
