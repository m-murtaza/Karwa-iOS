//
//  MPGSSession.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/28/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class MPGSSession
{
    var sessionId: String
    var apiVersion: String
    
    init(_ sessionId: String, _ apiVersion: String)
    {
        self.sessionId = sessionId
        self.apiVersion = apiVersion
    }
}
