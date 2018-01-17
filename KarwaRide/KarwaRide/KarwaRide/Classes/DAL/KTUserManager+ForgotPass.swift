//
//  KTUserManager+ForgotPass.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

extension KTUserManager
{
    func sendForgotPassRequest(phone: String, password: String,completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : NSMutableDictionary = [Constants.UpdatePassParam.Phone : phone,
                                           Constants.UpdatePassParam.Password: password]
        
        KTWebClient.sharedInstance.post(uri: Constants.APIURL.ForgotPass, param: param as! [String : Any]) { (status, response) in
            if status != true
            {
                completionBlock(Constants.APIResponseStatus.FAILED_API,response)
            }
            else
            {
                if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS
                {
                    completionBlock(response[Constants.ResponseAPIKey.Status] as! String, response as! [AnyHashable : Any])
                }
                else
                {
                    completionBlock(response[Constants.ResponseAPIKey.Status] as! String,response[Constants.ResponseAPIKey.MessageDictionary] as! [AnyHashable:Any])
                }
            }
        }
        
    }
}
