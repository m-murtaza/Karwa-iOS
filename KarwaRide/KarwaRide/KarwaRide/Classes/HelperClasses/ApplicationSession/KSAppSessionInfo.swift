//
//  KSAppSessionInfo.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/20/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KSAppSessionInfo: NSObject {

    //MARK: - Singleton
    private override init()
    {
        super.init()
    }
    
    static let currentSession = KSAppSessionInfo()
 
    var sessionId : String?
    var phone : String?
    var pushToken : String?
    
}
