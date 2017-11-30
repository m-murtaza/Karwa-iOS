//
//  KSWebClient.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import Alamofire

//typealias KSWebClientCompletionBlock = (_ success: Bool, _ response: Any) -> Void

class KTWebClient: NSObject {

    var baseURL : String?
    var sessionId : String?
    
    //MARK: - Singleton
    private override init()
    {
        super.init()
        self.baseURL = KTConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.RequestTimeOut
        _ = Alamofire.SessionManager(configuration: configuration)
    }
    
    static let sharedInstance = KTWebClient()
    
    //MARK: - Functions
//    func testServerCall ()
//    {
//    
//        //KSConfiguration.sharedInstance.valueForKey(key: "Tetete")
//        
//        let url : String = KSConfiguration.sharedInstance.envValue(forKey: "BaseAPIURL")
//        
//        Alamofire.request("https://httpbin.org/get").responseString { response in
//            print("Response String: \(String(describing: response.result.value))")
//        }.responseJSON { (response) in
//            print("Response JSON \(String(describing: response.result.value))")
//        }
//        
//    }
    
    func post(uri: String, param: [String : Any], completion completionBlock:@escaping  KTResponseCompletionBlock)
    {
        sendRequest(httpMethod: .post, uri: uri, param: param, completion: completionBlock)
    }
    
    func  get(uri: String, param: Parameters?, completion completionBlock:@escaping KTResponseCompletionBlock)
    {
        sendRequest(httpMethod: .get, uri: uri, param: param,completion: completionBlock)
    }
    
    private func sendRequest(httpMethod: HTTPMethod, uri: String, param: Parameters?, completion  completionBlock:@escaping  KTResponseCompletionBlock)
    {
        
        //Creating complet Url
        let url = baseURL! + uri
        
        var httpHeaders : [String:String] = [:]
        httpHeaders["Content-Type"] = "application/json"
        
        //TODO: Add Session id in request header
        if let sessionId = KTAppSessionInfo.currentSession.sessionId , !(KTAppSessionInfo.currentSession.sessionId?.isEmpty)!
        {
            httpHeaders["Session-ID"] = sessionId
        }
        
        Alamofire.request(url,
                          method: httpMethod,
                          parameters : param,
                          headers:httpHeaders).validate().responseJSON { (response) -> Void in
                            
                            guard response.result.isSuccess else {
                                
                                //TODO: Handle specific errors.
                                
                                let statusCode = response.response?.statusCode
                                let error : NSDictionary = ["ErrorCode" : statusCode as Any,
                                                            "Message" : response.result.error?.localizedDescription as Any]
                                completionBlock(false,error as! [AnyHashable : Any])
                                return
                            }
                            
                            guard let responseJSON = response.result.value as? [String: Any] else {
                                let error : NSDictionary = ["ErrorCode" : 1001,
                                                            "Message" : "Invalid tag information received from the service"]
                                
                                completionBlock(false,error as! [AnyHashable : Any])
                                return
                            }
                            
                            print(responseJSON)
                            completionBlock(true,responseJSON)
                        }
    }
}
