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
            user.customerType = response["CustomerType"] as! Int32
            user.name = response["Name"] as? String
            user.phone = response["Phone"] as? String
            user.email = response["Email"] as? String
            user.sessionId = response["SessionID"] as? String
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
        if runFirstTimeAfterMajorUpdate() {
            //Is running first time after Major Update
            userLoginInOldApplication(completion: completion)
        }
        else
        {
            
            
        }
        
    }
    
    private let appRunBeforeAfterMajorUpdateKey : String = "appRunBeforeAfterMajorUpdate"
    private func runFirstTimeAfterMajorUpdate() -> Bool
    {
        return true;
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
            KTAppSessionInfo.currentSession.sessionId = "7c2e2fd2b616819e274bc8f9d125f6aa"//sessionId
            KTAppSessionInfo.currentSession.phone = UserDefaults.standard.string(forKey: KTPhoneKey)!
            KTAppSessionInfo.currentSession.customerType = Int32(UserDefaults.standard.integer(forKey: KTCustomerTypeKey))
            
            //DispatchQueue.global(qos: .background).async {
              //  print("This is run on the background queue")
                
            self.fetchUserInfoFromServer(completion: completion)
            //}
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
                if response["S"] as! String == "SUCCESS"
                {
                    
                    self.saveUserInfoInDB(response["D"] as! [AnyHashable : Any],completion: completion)
                }
                else
                {
                    
                    completion(false)
                }
            }
        })
    }
}
