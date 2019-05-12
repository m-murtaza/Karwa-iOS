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
            
                let responseDic = response as! [String : Any]
            
                user.name = responseDic[Constants.EditAccountInfoParam.Name] as? String
                user.email = responseDic[Constants.EditAccountInfoParam.Email] as? String
            
                if let gender = responseDic[Constants.EditAccountInfoParam.gender] as? String, let genderIntVal = Int16(gender) {
                    user.gender = genderIntVal
                }

                if let emailVerified = responseDic[Constants.EditAccountInfoParam.isEmailVerified] as? String, let emailVerifiedInt = Int16(emailVerified) {
                    user.isEmailVerified = Bool(truncating: emailVerifiedInt as NSNumber)
                }

                if(!self.isNsnullOrNil(object: responseDic[Constants.EditAccountInfoParam.dob] as AnyObject))
                {
                    user.dob = Date.dateFromServerStringWithoutDefault(date: responseDic[Constants.EditAccountInfoParam.dob] as? String)
                }
            
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
            completionBlock(Constants.APIResponseStatus.SUCCESS,response)
            })
    }
    
    func resendEmail(completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSMutableDictionary = [Constants.LoginParams.DeviceType : Constants.DeviceTypes.iOS]
        
        self.post(url: Constants.APIURL.ResendEmail, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
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

