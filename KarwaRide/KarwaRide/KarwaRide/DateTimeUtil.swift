//
//  DateTimeUtil.swift
//  KarwaRide
//
//  Created by Sam Ash on 3/28/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

class DateTimeUtil
{
    static func currentTimeInMilliSeconds() -> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}
