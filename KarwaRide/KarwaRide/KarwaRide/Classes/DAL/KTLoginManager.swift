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

    // Mark: CRUD DB Operations
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
    
    // MARK: - Check Login
    
    func isUserLogin() -> Bool
    {
        var isAlreadyLogin : Bool = false
        if runFirstTimeAfterMajorUpdate() {
            //Is running first time after Major Update
            isAlreadyLogin = userFromOldSession()
        }
        else
        {
            
            
        }
        return isAlreadyLogin
    }
    
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
    private func userFromOldSession() -> Bool
    {
        var isUserLogin : Bool = true
        let sessionId : String? = UserDefaults.standard.string(forKey: KTSessionIdKey)
        if (sessionId ?? "").isEmpty {
            isUserLogin = false
        }
        else
        {
            KTAppSessionInfo.currentSession.sessionId = sessionId
            KTAppSessionInfo.currentSession.phone = UserDefaults.standard.string(forKey: KTPhoneKey)!
            KTAppSessionInfo.currentSession.customerType = UserDefaults.standard.integer(forKey: KTCustomerTypeKey)
        }
        return isUserLogin
    }
}
