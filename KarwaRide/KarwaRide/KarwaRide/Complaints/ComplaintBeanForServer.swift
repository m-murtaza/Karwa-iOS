//
//  ComplaintBeanForServer.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/13/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class ComplaintBeanForServer
{
    var bookingId: String
    var complaintType: Int
    var categoryId: Int
    var issueId: Int
    var remarks: String
    var tripType: Int16
    
    init(_ bookingId: String, _ complaintType: Int, _ categoryId: Int, _ issueId: Int, _ remarks: String, _ tripType: Int16)
    {
        self.bookingId = bookingId
        self.complaintType = complaintType
        self.categoryId = categoryId
        self.issueId = issueId
        self.remarks = remarks
        self.tripType = tripType
    }
}
