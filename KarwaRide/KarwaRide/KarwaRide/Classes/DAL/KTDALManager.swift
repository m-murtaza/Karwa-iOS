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
}
