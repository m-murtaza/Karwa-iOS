//
//  KTTimer.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/31/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class KTTimer: NSObject {
    
    //MARK: - Singleton
    private override init()
    {
        super.init()
    }
    
    static let sharedInstance = KTTimer()
    
    var isRunning : Bool = false
    var timer : Timer = Timer()
    
    func startMinTimer()  {
        if !(timer.isValid) {
            
            let calendar = Calendar.current
            let currentSecond = calendar.component(.second, from: Date())
            
            let fireDate : Date = (Date().addingTimeInterval((60.0 - Double(currentSecond) ) ))
            timer = Timer(fireAt: fireDate, interval: 60, target: self, selector: #selector(self.minuteTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer, forMode: .defaultRunLoopMode)
            
            
        }
    }
    
    func stoprMinTimer() {
        if timer.isValid  {
            
            timer.invalidate()
            
        }
    }
    
    @objc func minuteTimer()  {
        NotificationCenter.default.post(name: Notification.Name(Constants.Notification.MinuteChanged), object: nil, userInfo: nil)
    }
    
}
