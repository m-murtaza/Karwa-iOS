//
//  Date+Utils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
extension NSDate {
    
//    static func dateFromServerString(date strDate:String?) ->NSDate {
//        var date : NSDate?
//        
//        if(strDate != nil && !(strDate?.isEmpty)!) {
//            let formatter : DateFormatter = DateFormatter()
//            formatter.dateFormat = Constants.SERVER_DATE_FORMAT
//            if formatter.date(from: strDate!) != nil {
//                date  = formatter.date(from: strDate!)! as NSDate
//            }
//            else {
//                date = defaultDate()
//            }
//        }
//        else {
//            date = defaultDate()
//        }
//        return date!
//    }
//    
//    static func defaultDate() -> NSDate {
//        return NSDate(timeIntervalSince1970: 0)
//    }
    
//    func year() -> String {
//        let formatter : DateFormatter = DateFormatter()
//        formatter.dateFormat = "yyyy"
//        //formatter.dateStyle = .medium
//        let str = formatter.string(from: self as Date)
//        
//        return str.uppercased()
//    }
    
//    func dayOfMonth() -> String {
//        let formatter : DateFormatter = DateFormatter()
//        formatter.dateFormat = "dd"
//        //formatter.dateStyle = .medium
//        let str = formatter.string(from: self as Date)
//        
//        return str.uppercased()
//    }
//    
//    func dayNumberOfWeek() -> Int? {
//        return Calendar.current.dateComponents([.weekday], from: self as Date).weekday
//    }
//    
//    func timeWithAMPM() -> String {
//        let formatter : DateFormatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        //formatter.dateStyle = .medium
//        let str = formatter.string(from: self as Date)
//        
//        return str
//    }
//    
//    func dayOfWeek() -> String {
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE"
//        let fullDay = dateFormatter.string(from: self as Date).capitalized
//        let shortDay = fullDay.substring(to: fullDay.index(fullDay.startIndex, offsetBy: 3)).uppercased()
//        return shortDay
//    }
//    
//    func threeLetterMonth() ->String {
//        
//        let formatter : DateFormatter = DateFormatter()
//        formatter.dateFormat = "MMM"
//        //formatter.dateStyle = .medium
//        let str = formatter.string(from: self as Date)
//        
//        return str.uppercased()
//    }
}

extension Date {
    
    func timeWithAMPM() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self as Date)
        
        return str
    }
    
    static func dateFromServerString(date strDate:String?) ->Date {
        var date : Date?
        
        if(strDate != nil && !(strDate?.isEmpty)!) {
            let formatter : DateFormatter = DateFormatter()
            formatter.dateFormat = Constants.SERVER_DATE_FORMAT
            if formatter.date(from: strDate!) != nil {
                date  = formatter.date(from: strDate!)! 
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
    
    static func dateFromServerStringWithoutDefault(date strDate:String?) ->Date? {
        var date : Date?
        
        if(strDate != nil && !(strDate?.isEmpty)!) {
            let formatter : DateFormatter = DateFormatter()
            formatter.dateFormat = Constants.SERVER_DATE_FORMAT
            if formatter.date(from: strDate!) != nil {
                date  = formatter.date(from: strDate!)!
            }
        }

        return date
    }
    
    static func defaultDate() -> Date {
        return Date(timeIntervalSince1970: 0)
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
        } else if let hr = interval.hour,hr > 0, hour > 0{
            return hr == 1 ? "\(hr)" + " " + "hour ago" :
                "\(hr)" + " " + "hours ago"
        } else if let min = interval.minute, min > 0, minute > 0{
            return min == 1 ? "\(min)" + " " + "min ago" :
                "\(min)" + " " + "mins ago"
        } else {
            return "a moment ago"
            
        }
    }
    
    //DUe to server side chotiyapa.
    func deviceTimeZone() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        return Date(timeIntervalSinceReferenceDate: (self.timeIntervalSince1970 - timeZoneOffset))
    }
    
    //DUe to server side chotiyapa.
    func serverTimeStamp() -> TimeInterval {
        
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        return self.timeIntervalSince1970 + timeZoneOffset

    }

    //DUe to server side chotiyapa.
    func getServerFormatDate() -> String {
        return year() + "-" + String(monthNumber()) + "-" + dayOfMonth()
    }
    
    func getUIFormatDate() -> String {
        return String(dayOfMonth()) + " " + month() + " " + year()
    }
    
    func monthNumber() -> Int {
        if(dayOfMonth() == "1" || dayOfMonth() == "01")
        {
            return (month + 1)
        }
        else
        {
            return month
        }
    }

    func month() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MMM"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self)
        
        return str.uppercased()
    }
  
  func toString(format: String = "dd MMM yyyy") -> String {
    let formatter : DateFormatter = DateFormatter()
    formatter.dateFormat = format
    let str = formatter.string(from: self)
    return str.uppercased()
  }
    
    func year() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let str = formatter.string(from: self)
        
        return str.uppercased()
    }
    
    func dayOfMonth() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd"
        //formatter.dateStyle = .medium
        let str = formatter.string(from: self)

        return str.uppercased()
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self as Date).weekday
    }
    
//    func timeWithAMPM() -> String {
//        let formatter : DateFormatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        //formatter.dateStyle = .medium
//        let str = formatter.string(from: self as Date)
//
//        return str
//    }
    
    func dayOfWeek() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let fullDay = dateFormatter.string(from: self).capitalized
        let shortDay = fullDay.substring(to: fullDay.index(fullDay.startIndex, offsetBy: 3)).uppercased()
        return shortDay
    }
    
    func threeLetterMonth() ->String {
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let str = formatter.string(from: self)
        
        return str.uppercased()
    }
    
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}
