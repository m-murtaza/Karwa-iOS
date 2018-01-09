//
//  KTUserManager+SignUp.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

extension KTUserManager
{
    
    func signUp(name: String, mobileNo:String,email:String,password:String,completion completionBlock:@escaping KTResponseCompletionBlock) -> Void {
        let param : NSMutableDictionary = [Constants.SignUpParams.Name : name,
                                           Constants.SignUpParams.Phone : mobileNo,
                                           Constants.SignUpParams.Email : email,
                                           Constants.SignUpParams.Password: password]
        KTWebClient.sharedInstance.post(uri: Constants.APIURL.SignUp, param: param as! [String : Any]) { (status, response) in
            if status != true
            {
                
                completionBlock(status,response)
            }
            else
            {
                NSLog("Success")
                
            }
        }
    }
}
