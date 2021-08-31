//
//  KTUserManager+AccountEdit.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import MagicalRecord

let USER_PREF_SYNC_TIME = "ProfileSyncTime"

extension KTUserManager {
    
    fileprivate func saveUserData(_ response: [AnyHashable : Any])
    {
        let responseDic = response as! [String : Any]

//        guard let phone = responseDic[Constants.LoginResponseAPIKey.Phone] as? String else {
//            return
//        }
//
//        let predicate : NSPredicate = NSPredicate(format:"phone = %d" , phone)
//        KTUser.mr_deleteAll(matching: predicate)
        
        let user : KTUser = self.loginUserInfo()!
        user.name = responseDic[Constants.EditAccountInfoParam.Name] as? String
        user.email = responseDic[Constants.EditAccountInfoParam.Email] as? String
        user.isEmailVerified = responseDic[Constants.EditAccountInfoParam.isEmailVerified] as? Int == 1 ? true : false
        
        if let otpEnabled = (responseDic[Constants.EditAccountInfoParam.Preference] as? [String:Int])?[Constants.EditAccountInfoParam.BookingOtp] {
            UserDefaults.standard.setValue(otpEnabled == 1 ? true : false, forKey: "OTPEnabled")
            UserDefaults.standard.synchronize()
        }
    
        
         if let gender = responseDic[Constants.EditAccountInfoParam.gender] as? String, let genderIntVal = Int16(gender) {
            user.gender = genderIntVal
        }
        
        if(!self.isNsnullOrNil(object: responseDic[Constants.EditAccountInfoParam.dob] as AnyObject))
        {
            user.dob = Date.dateFromServerStringWithoutDefault(date: responseDic[Constants.EditAccountInfoParam.dob] as? String)
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
    
    }
    
    fileprivate func saveOtpStatus(_ response: [AnyHashable : Any])
    {
        let responseDic = response as! [String : Any]
       
        if let otpEnabled = responseDic[Constants.EditAccountInfoParam.BookingOtp] as? Int {
            UserDefaults.standard.setValue(otpEnabled == 1 ? true : false, forKey: "OTPEnabled")
            UserDefaults.standard.synchronize()
        }
    
    }
    
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
            
            self.saveUserData(response)
            
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
    
    public func updateUserInfo(param : [String:Any], completion completionBlock:@escaping KTDALCompletionBlock) {
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
    
    func updateOTP(otp: String, completion completionBlock:@escaping KTDALCompletionBlock) {
        let param : NSMutableDictionary = [Constants.OtpParams.otp : otp]
        
        updateOtpEnabledStatus(param: param as! [String : Any], completion: { (status, response) in
            self.saveOtpStatus(response)
            completionBlock(Constants.APIResponseStatus.SUCCESS,response)
            
        })
    }
    
    func updateOtpEnabledStatus(param : [String:Any], completion completionBlock:@escaping KTDALCompletionBlock) {
        self.post(url: Constants.APIURL.OtpEnableStatus, param: param, completion: completionBlock, success: {
            (responseData,cBlock) in
            completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        })

    }

    func syncUserProfile(completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : [String: Any] = [Constants.SyncParam.BookingList: syncTime(forKey:USER_PREF_SYNC_TIME)]
        
        self.get(url: Constants.APIURL.SignUp, param: param, completion: completionBlock) { (response, cBlock) in
            
            self.saveUserData(response)
            self.updateSyncTime(forKey: USER_PREF_SYNC_TIME)

            cBlock(Constants.APIResponseStatus.SUCCESS,[Constants.ResponseAPIKey.Data:response])
        }
    }
}

