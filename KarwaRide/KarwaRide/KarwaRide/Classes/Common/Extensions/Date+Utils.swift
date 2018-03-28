//
//  Date+Utils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
extension NSDate {
    
    static func dateFromServerString(date strDate:String?) ->NSDate {
        var date : NSDate?
        
        if(strDate != nil && !(strDate?.isEmpty)!) {
            let formatter : DateFormatter = DateFormatter()
            formatter.dateFormat = Constants.SERVER_DATE_FORMAT
            if formatter.date(from: strDate!) != nil {
                date  = formatter.date(from: strDate!)! as NSDate
            }
            else {
                date = defaultDate()
            }
        }
        else {
            date = defaultDate()
        }
        return date!
    }
    
    static func defaultDate() -> NSDate {
        return NSDate(timeIntervalSince1970: 0)
    }
    
    func year() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str.uppercased()
    }
    
    func dayOfMonth() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str.uppercased()
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self as Date).weekday
    }
    
    func timeWithAMPM() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str
    }
    
    func dayOfWeek() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let fullDay = dateFormatter.string(from: self as Date).capitalized
        let shortDay = fullDay.substring(to: fullDay.index(fullDay.startIndex, offsetBy: 3)).uppercased()
        return shortDay
    }
    
    func threeLetterMonth() ->String {
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MMM"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str.uppercased()
    }
}

extension Date {
    
    func timeWithAMPM() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str
    }
}
