//
//  KSWebClient.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import Alamofire

typealias KSWebClientCompletionBlock = (_ success: Bool, _ response: Any) -> Void

class KSWebClient: NSObject {

    var baseURL : String?
    
    //MARK: - Singleton
    private override init()
    {
        super.init()
        self.baseURL = KSConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        _ = Alamofire.SessionManager(configuration: configuration)
    }
    
    static let sharedInstance = KSWebClient()
    
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
    
    func post(uri: String, param: [String : Any], completion completionBlock: KSWebClientCompletionBlock)
    {
        sendRequest(httpMethod: .post, uri: uri, param: param, completion: completionBlock)
    }
    
    func  get(uri: String, param: [String : Any], completion completionBlock: KSWebClientCompletionBlock)
    {
        sendRequest(httpMethod: .get, uri: uri, param: param,completion: completionBlock)
    }
    
    private func sendRequest(httpMethod: HTTPMethod, uri: String, param: [String : Any], completion completionBlock: KSWebClientCompletionBlock)
    {
        
        //Creating complet Url
        let url = baseURL! + uri
        
        var httpHeaders : [String:String] = [:]
        httpHeaders["Content-Type"] = "application/x-www-form-urlencoded"
        
        //TODO: Add Session id in request header
        if let sessionId = KSAppSessionInfo.currentSession.sessionId , !(KSAppSessionInfo.currentSession.sessionId?.isEmpty)!
        {
            httpHeaders["Session-ID"] = sessionId
        }
        
        Alamofire.request(url,
                          method: httpMethod,
                          parameters : param,
                          headers:httpHeaders).validate().responseJSON { (response) -> Void in
                            
                            switch response.result {
                            case .success:
                                print("Validation Successful")
                            case .failure(let error):
                                print(error)
                            }
        }
        //Alamofire.request("https://httpbin.org/post", method: .post, parameters: param, encoding: URLEncoding.default)
    }
}
