//
//  KSConfiguration.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/19/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTConfiguration: NSObject {

    var resourceFileDictionary: NSDictionary?
    var environment : String?
    
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
}
