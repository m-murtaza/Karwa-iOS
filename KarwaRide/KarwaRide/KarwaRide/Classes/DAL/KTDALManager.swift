//
//  KSDALManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/4/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTDALManager: KTBase {

    func delete(url: String, param: [String:Any]?,completion completionBlock: @escaping KTDALCompletionBlock,success successBlock:@escaping KTDALSuccessBlock) -> Void {
        KTWebClient.sharedInstance.delete(uri: url, param: param) { (status, response) in
            
            self.handleAPIResponse(status: status, response: response, completion: completionBlock,success: successBlock)
        }
    }
    
    func get(url: String, param: [String:Any]?,completion completionBlock: @escaping KTDALCompletionBlock,success successBlock:@escaping KTDALSuccessBlock) -> Void {
        KTWebClient.sharedInstance.get(uri: url, param: param) { (status, response) in
            
            self.handleAPIResponse(status: status, response: response, completion: completionBlock,success: successBlock)
        }
    }
    
    func post(url: String, param: [String:Any]?,completion completionBlock: @escaping KTDALCompletionBlock,success successBlock:@escaping KTDALSuccessBlock) -> Void {
        KTWebClient.sharedInstance.post(uri: url, param: param) { (status, response) in
            
            self.handleAPIResponse(status: status, response: response, completion: completionBlock,success: successBlock)
        }
    }
    
    func handleAPIResponse(status: Bool,response: [AnyHashable: Any],completion completionBlock:@escaping KTDALCompletionBlock,success successBlock:@escaping KTDALSuccessBlock) -> Void {
        if !status
        {
            //In Case of Network Fail.
            completionBlock(Constants.APIResponseStatus.FAILED_NETWORK, response)
        }
        else
        {
            //IF no error on network layer
            if response[Constants.ResponseAPIKey.Status] as! String != Constants.APIResponseStatus.SUCCESS
            {
                //fail on API level
                completionBlock(response[Constants.ResponseAPIKey.Status] as! String,response[Constants.ResponseAPIKey.MessageDictionary] as! [AnyHashable:Any])
            }
            else
            {
                if (response[Constants.ResponseAPIKey.Data] as? [Any]) != nil
                {
                    successBlock([Constants.ResponseAPIKey.Data:response[Constants.ResponseAPIKey.Data]!] as [AnyHashable:Any], completionBlock)
                }
                else
                {
                    successBlock(((response[Constants.ResponseAPIKey.Data] != nil) ? response[Constants.ResponseAPIKey.Data] : ["":""])  as! [AnyHashable:Any],completionBlock)
                }
                
                //self.handleAPISuccess(status: status, response: response, completion: completionBlock)
            }
            
        }
    }
    
    
    func saveInDb() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    /*func handleAPISuccess(status: Bool,response: [AnyHashable: Any],completion completionBlock:@escaping KTDALCompletionBlock) -> Void {
        
    }*/
    
    func isNsnullOrNil(object : AnyObject?) -> Bool
    {
        if (object is NSNull) || (object == nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func syncTime(forKey key: String) -> String {
        //return "0"
        var syncDate = UserDefaults.standard.object(forKey: key) as? Date
        if syncDate == nil {
            syncDate = self.defaultSyncDate()
        }
        let syncTimeInterval: TimeInterval = (syncDate?.timeIntervalSince1970)!
        let strSyncTimeInterval = String(format: "%.0f", syncTimeInterval)
        return strSyncTimeInterval
    }
    
    func updateSyncTime(forKey key: String) {
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(Date(), forKey: key)
        defaults?.synchronize()
    }
    
    func removeSyncTime(forKey key:String) {
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.removeObject(forKey: key)
        defaults?.synchronize()
    }
    
    func defaultSyncDate() -> Date? {
        return Date(timeIntervalSince1970: 0)
        //Default date of 1970
    }
}
