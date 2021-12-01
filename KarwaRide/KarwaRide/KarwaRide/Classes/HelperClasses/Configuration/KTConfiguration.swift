//
//  KSConfiguration.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

enum ENVIRONMENT: String {
    case PROD = "PROD"
    case STAGE = "STAGE"
}

class KTConfiguration: NSObject {

    var resourceFileDictionary: NSDictionary?
    var environment : String?
    var isRSEnabled: Bool?
    var isIconicLimousineEnabled: Bool?
    
    var MERCHANT_ID: String?
    var GATEWAY_REGION: GatewayRegion?
    var APPLE_PAY_MERCHANT_ID: String?
    
    //MARK : Singleton
    private override init() {
        super.init()
        //Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        self.getDevelopmentEnvironment()
    }
    
    static let sharedInstance = KTConfiguration()
    
    func getDevelopmentEnvironment() {
        if(resourceFileDictionary != nil)
        {
            environment = resourceFileDictionary?.value(forKey: "Development Environment") as? String
        }
    }
    
    //Returns value from info.plist file on basis of Development Envoirnment
    func envValue(forKey : String) -> String {
        
        var configValue : String = ""
        if(environment != nil)
        {
            var configDictionary : Dictionary? = resourceFileDictionary?.object(forKey: forKey) as? Dictionary<String,String>
            
            
            if(configDictionary?[environment!] != nil)
            {
                configValue = (configDictionary?[environment!])!
            }
            
            //configValue = configDictionary.value(forKey: environment)
        }
        return configValue
    }
    
    func checkRSEnabled() -> Bool {
        if(isRSEnabled == nil){
            isRSEnabled = resourceFileDictionary?.value(forKey: "isRSEnabled") as? Bool
        }
        return isRSEnabled ?? false
    }
    
    func checkIconicLimousineEnabled() -> Bool {
        if(isIconicLimousineEnabled == nil){
            isIconicLimousineEnabled = resourceFileDictionary?.value(forKey: "isIconicLimousineEnabled") as? Bool
        }
        return isIconicLimousineEnabled ?? false
    }
    
    func setEnvironment(environment: ENVIRONMENT) {
        self.environment = environment.rawValue
        if environment == .PROD {
            self.MERCHANT_ID = "KTRQNB01"
            self.GATEWAY_REGION = .asiaPacific
            self.APPLE_PAY_MERCHANT_ID = "merchant.karwa.KTQNB01"
        }
        else {
            self.MERCHANT_ID = "KTQNB01A"
            self.GATEWAY_REGION = .mtf
            self.APPLE_PAY_MERCHANT_ID = "merchant.mowasalat.karwa.taxi"
        }
        
        Constants.MERCHANT_ID = self.MERCHANT_ID!
        Constants.GATEWAY_REGION = self.GATEWAY_REGION!
        Constants.APPLE_PAY_MERCHANT_ID = self.APPLE_PAY_MERCHANT_ID!
        
        SharedPrefUtil.setSharedPref(SharedPrefUtil.ENVIRONMENT, environment.rawValue)
    }
}
