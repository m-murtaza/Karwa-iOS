//
//  KSWebClient.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

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
        guard Connectivity.isConnectedToInternet else {
            let error : NSDictionary = [Constants.ResponseAPIKey.Title : "No Internet" as Any,
                                        Constants.ResponseAPIKey.Message : "Internet not available" as Any]
            completionBlock(false,error as! [AnyHashable : Any])
            return
        }
        //Creating complet Url
        let url = baseURL! + uri
        
        var httpHeaders : [String:String] = [:]
        httpHeaders["Content-Type"] = "application/x-www-form-urlencoded"
        
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
                                
                                //TODO: Handle 401 UnAuthorize
                                
                                print("ErrorCode: \(String(describing:  response.response?.statusCode))")
                                print("Message: \(String(describing: response.result.error?.localizedDescription))")

                                let error : NSDictionary = [Constants.ResponseAPIKey.Title : "Ops!",
                                    Constants.ResponseAPIKey.Message: "Something went wrong"]
                                
                                completionBlock(false,error as! [AnyHashable : Any])
                                return
                            }
                            
                            guard let responseJSON = response.result.value as? [String: Any] else {
                                
                                print("ErrorCode: 1001")
                                print("Message: Invalid tag information received from the service")
                                
                                let error : NSDictionary = [Constants.ResponseAPIKey.Title  : 1001,
                                                            Constants.ResponseAPIKey.Message : "Invalid tag information received from the service"]
                                
                                completionBlock(false,error as! [AnyHashable : Any])
                                return
                            }
                            
                            print(responseJSON)
                            completionBlock(true,responseJSON)
                        }
    }
}
