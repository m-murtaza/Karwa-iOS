//
//  KSAppSessionInfo.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/20/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTAppSessionInfo: NSObject {

    //MARK: - Singleton
    private override init()
    {
        super.init()
    }
    
    static let currentSession = KTAppSessionInfo()
 
    var sessionId : String?
    var countryCode : String? = "+974"
    var phone : String?
    var pushToken : String?
    var customerType : CustomerType?
 
    func removeCurrentSession()  {
        sessionId = nil
        phone = nil
        countryCode = nil
        customerType = CustomerType.STANDARD
        //pushToken = nil
    }
}


