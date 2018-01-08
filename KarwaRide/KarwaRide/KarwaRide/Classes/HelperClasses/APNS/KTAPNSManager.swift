//
//  KSAPNSManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/21/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import UserNotifications

class KTAPNSManager: NSObject {

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate 
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            //UIApplication.shared.registerForRemoteNotifications()
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    
    func deviceTokenReceived(deviceToken : Data)  {
        KTAppSessionInfo.currentSession.pushToken = tokenString(deviceToken)
        //let _ : String = tokenString(deviceToken)
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any])
    {
        print("Recived: \(userInfo)")
        
    }
    
    private func tokenString(_ deviceToken:Data) -> String{
        //code to make a token string
        let bytes = [UInt8](deviceToken)
        var token = ""
        for byte in bytes{
            token += String(format: "%02x",byte)
        }
        return token
    }
}
