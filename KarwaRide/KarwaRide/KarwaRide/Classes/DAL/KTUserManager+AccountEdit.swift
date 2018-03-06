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
    
    func updateUserInfo(name: String, email: String, completion completionBlock:@escaping KTDALCompletionBlock) {
        let param : NSMutableDictionary = [Constants.EditAccountInfoParam.Name : name,
                                           Constants.EditAccountInfoParam.Email : email]
        
        updateUserInfo(param: param as! [String : Any], completion: completionBlock)
    }
    
    private func updateUserInfo(param : [String:Any], completion completionBlock:@escaping KTDALCompletionBlock) {
        self.post(url: Constants.APIURL.UpdateUserAccount, param: param, completion: completionBlock, success: {
            (responseData,cBlock) in
            
            //do {
                let user : KTUser = self.loginUserInfo()!
                user.name = param[Constants.EditAccountInfoParam.Name] as? String
                user.email = param[Constants.EditAccountInfoParam.Email] as? String
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            //}
            //catch _{
                
              //  completionBlock(Constants.APIResponseStatus.FAILED_DB,[:])
            //}
        })
    }
}

