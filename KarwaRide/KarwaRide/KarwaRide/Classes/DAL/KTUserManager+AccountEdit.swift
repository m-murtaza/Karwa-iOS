//
//  KTUserManager+AccountEdit.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import MagicalRecord
extension KTUserManager {
    
    func updateUserInfo(
        name: String,
        email: String,
        dob: String,
        gender: Int16,
        completion completionBlock:@escaping KTDALCompletionBlock) {
        let param : NSMutableDictionary = [Constants.EditAccountInfoParam.Name : name,
                                           Constants.EditAccountInfoParam.Email : email,
                                           Constants.EditAccountInfoParam.dob : dob,
                                           Constants.EditAccountInfoParam.gender : gender
                                          ]
        
        updateUserInfo(param: param as! [String : Any], completion: { (status, response) in
            
                let user : KTUser = self.loginUserInfo()!
                user.name = param[Constants.EditAccountInfoParam.Name] as? String
                user.email = param[Constants.EditAccountInfoParam.Email] as? String
            //TODO: parse date nicely please
            
                if(!self.isNsnullOrNil(object: param[Constants.EditAccountInfoParam.dob] as AnyObject))
                {
                    user.dob = Date.dateFromServerString(date: param[Constants.EditAccountInfoParam.dob] as? String)
                }
//                user.dob = param[Constants.EditAccountInfoParam.dob] as? Date
                user.gender = param[Constants.EditAccountInfoParam.gender] as? Int16 ?? 0
            user.isEmailVerified = (param[Constants.EditAccountInfoParam.isEmailVerified] as? Int) == 0 ? false: true

                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
            completionBlock(Constants.APIResponseStatus.SUCCESS,response)
            })
    }
    
    func updatePassword(oldPassword: String, password: String, completion completionBlock:@escaping KTDALCompletionBlock) {
        let param : NSMutableDictionary = [Constants.EditAccountInfoParam.OldPassword : oldPassword,
                                           Constants.EditAccountInfoParam.NewPassword : password]
        
        updateUserInfo(param: param as! [String : Any], completion: completionBlock)
    }
    
    func updateDeviceTokenOnServer(token : String, completion completionBlock: @escaping KTDALCompletionBlock)  {
        let param : [String : Any] = [Constants.DeviceTokenParam.DeviceToken: token]
        KTUserManager().updateUserInfo(param: param ,completion: completionBlock)
    }
    
    private func updateUserInfo(param : [String:Any], completion completionBlock:@escaping KTDALCompletionBlock) {
        self.post(url: Constants.APIURL.UpdateUserAccount, param: param, completion: completionBlock, success: {
            (responseData,cBlock) in
            
            //do {
                /*let user : KTUser = self.loginUserInfo()!
                user.name = param[Constants.EditAccountInfoParam.Name] as? String
                user.email = param[Constants.EditAccountInfoParam.Email] as? String
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()*/
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            //}
            //catch _{
                
              //  completionBlock(Constants.APIResponseStatus.FAILED_DB,[:])
            //}
        })
    }
}

