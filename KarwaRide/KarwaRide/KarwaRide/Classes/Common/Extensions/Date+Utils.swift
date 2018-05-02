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
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hr = interval.hour, hour > 1{
            return hr == 1 ? "\(hr)" + " " + "hour ago" :
                "\(hr)" + " " + "hours ago"
        } else if let min = interval.minute, minute > 1{
            return min == 1 ? "\(min)" + " " + "minute ago" :
                "\(min)" + " " + "minutes ago"
        } else {
            return "a moment ago"
            
        }
        
    }

}
