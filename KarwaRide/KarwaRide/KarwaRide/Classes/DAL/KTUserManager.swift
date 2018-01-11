//
//  KTLoginManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/28/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTUserManager: KTDALManager {

    // MARK: - CRUD DB Operations
    func saveUserInfoInDBFromAppSession()
    {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
            
            let user : KTUser = KTUser.mr_createEntity()!
            user.customerType = KTAppSessionInfo.currentSession.customerType!
            //user.name = KTAppSessionInfo.currentSession.
            user.phone = KTAppSessionInfo.currentSession.phone
            //user.email = "ualeem@faad.com"
            
        }, completion: {(_ success: Bool, _ error: Error?) -> Void in
           
        })
    }
    
    func saveUserInfoInDB(_ response: [AnyHashable: Any], completion:@escaping (Bool) -> Void )
    {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
           _ = KTUser.mr_truncateAll(in: localContext)
            let user : KTUser = KTUser.mr_createEntity(in: localContext)! //KTUser.mr_createEntity()!
            user.customerType = response[Constants.LoginResponseAPIKey.CustomerType] as! Int32
            user.name = response[Constants.LoginResponseAPIKey.Name] as? String
            user.phone = response[Constants.LoginResponseAPIKey.Phone] as? String
            user.email = response[Constants.LoginResponseAPIKey.Email] as? String
            user.sessionId = response[Constants.LoginResponseAPIKey.SessionID] as? String
        }, completion: {(_ success: Bool, _ error: Error?) -> Void in
            completion(success)
        })
    }
    
    func fetchUser() -> KTUser?
    {
        var user : KTUser? = nil
        var users: [NSManagedObject]!
        users = KTUser.mr_findAll()
        if users.count > 0 {
            user = users[0] as? KTUser
        }
        return user
    }
    
    // MARK: - Check Login
    
    func isUserLogin(completion:@escaping (Bool) -> Void)
    {
        completion(false)
        return
            //-- Remove above two lines.
        
        if runFirstTimeAfterMajorUpdate() {
            //Is running first time after Major Update
            userLoginInOldApplication(completion: completion)
        }
        else
        {
            //Login check in current version.
            isUserAlreadyLogin(completion : completion)
        }
    }
    // Mark: - Login User in new Application
    private func isUserAlreadyLogin(completion: @escaping (Bool) -> Void)
    {
        let loginUser : KTUser? = fetchUser()
        guard (loginUser != nil) else {
            
            completion(false)
            return
        }
        KTAppSessionInfo.currentSession.customerType = loginUser?.customerType
        KTAppSessionInfo.currentSession.phone = loginUser?.phone
        KTAppSessionInfo.currentSession.sessionId = loginUser?.sessionId
        completion(true)
        
    }
    func login(params : NSMutableDictionary,url : String?,completion completionBlock: @escaping KTDALCompletionBlock)  {
        
        params[Constants.LoginParams.DeviceType] = Constants.DeviceTypes.iOS
        if KTUtils.isObjectNotNil(object: KTAppSessionInfo.currentSession.pushToken as AnyObject)
        {
            params[Constants.LoginParams.DeviceToken] = [KTAppSessionInfo.currentSession.pushToken]
        }
        else
        {
            params[Constants.LoginParams.DeviceToken] = ""
        }
        //params[Constants.LoginParams.DeviceToken] = "1234567891234567891234567891234567891234"
        
        KTWebClient.sharedInstance.post(uri: url!, param: params as! [String : Any], completion: { (status, response) in
            if status != true
            {
                
                completionBlock(Constants.APIResponseStatus.FAILED,response)
            }
            else
            {
                if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS
                {
                    
                    self.saveUserInfoInDB(response[Constants.ResponseAPIKey.Data] as! [AnyHashable : Any],completion: {(success:Bool) -> Void in
                        completionBlock(response[Constants.ResponseAPIKey.Status] as! String, response[Constants.ResponseAPIKey.Data] as! [AnyHashable : Any])
                    })
                }
                else
                {
                    completionBlock(response[Constants.ResponseAPIKey.Status] as! String,response[Constants.ResponseAPIKey.MessageDictionary] as! [AnyHashable:Any])
                }
            }
        })
    }
    
    func login(phone: String, password: String,completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let params : NSMutableDictionary = [Constants.LoginParams.Phone : phone,
                                            Constants.LoginParams.Password: password]
        
        self.login(params: params,url: Constants.APIURL.Login, completion: completionBlock)
        
    }
    
    // Mark: - Login User in old Application
    private let appRunBeforeAfterMajorUpdateKey : String = "appRunBeforeAfterMajorUpdate"
    private func runFirstTimeAfterMajorUpdate() -> Bool
    {
        let appRunBeforeAfterMajorUpdate : Bool = UserDefaults.standard.bool(forKey: appRunBeforeAfterMajorUpdateKey)
        
        UserDefaults.standard.set(true, forKey: appRunBeforeAfterMajorUpdateKey)
        guard appRunBeforeAfterMajorUpdate else {
            return true         //appRunBeforeAfterMajorUpdate= false or not found
        }
        
        return false
    }
    
    private let KTPhoneKey = "KSSessionPhone"
    private let KTSessionIdKey = "KSSessionID"
    private let KTCustomerTypeKey = "KSCustomerType"
    
    //If User was login in older version then this function will populate KTAppSessionInfo class and return true.
    //else return false.
    private func userLoginInOldApplication(completion: @escaping (Bool) -> Void)
    {
        let sessionId : String? = UserDefaults.standard.string(forKey: KTSessionIdKey)
        if (sessionId ?? "").isEmpty {
            completion(false)
        }
        else
        {
            KTAppSessionInfo.currentSession.sessionId = sessionId
            KTAppSessionInfo.currentSession.phone = UserDefaults.standard.string(forKey: KTPhoneKey)!
            KTAppSessionInfo.currentSession.customerType = Int32(UserDefaults.standard.integer(forKey: KTCustomerTypeKey))
            
            self.fetchUserInfoFromServer(completion: completion)
            
        }
    }
    
    // Mark: API User Info
    private func fetchUserInfoFromServer(completion:@escaping (Bool) -> Void) {
        KTWebClient.sharedInstance.get(uri: Constants.APIURL.GetUserInfo, param: nil, completion: { (status, response) in
            if status != true
            {
                //Its web API status, Not API success
                
                completion(false)
            }
            else
            {
                if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS
                {
                    
                    self.saveUserInfoInDB(response[Constants.ResponseAPIKey.Data] as! [AnyHashable : Any],completion: completion)
                }
                else
                {
                    
                    completion(false)
                }
            }
        })
    }
}
