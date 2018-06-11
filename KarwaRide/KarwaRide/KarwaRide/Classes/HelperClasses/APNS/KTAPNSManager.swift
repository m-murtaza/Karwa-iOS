//
//  KSAPNSManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/21/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import UserNotifications

let PUSH_TOKEN = "APNSToken"

class KTAPNSManager: NSObject {

    func registerForPushNotifications() {
        
        if  UserDefaults.standard.value(forKey: PUSH_TOKEN) == nil ||  (UserDefaults.standard.value(forKey: PUSH_TOKEN) as! String) == ""  {
        
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        }
        else {
            KTAppSessionInfo.currentSession.pushToken = (UserDefaults.standard.value(forKey: PUSH_TOKEN) as! String)
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
        let apnsString = tokenString(deviceToken)
        UserDefaults.standard.set(apnsString, forKey: PUSH_TOKEN)
        UserDefaults.standard.synchronize()
        
        KTAppSessionInfo.currentSession.pushToken = apnsString
        
        if KTAppSessionInfo.currentSession.phone != nil && KTAppSessionInfo.currentSession.phone != "" {
            updateDeviceTokenOnServer(token: apnsString)
        }
    }
    
    func updateDeviceTokenOnServer(token: String)  {
        KTUserManager().updateDeviceTokenOnServer(token: token) { (status, response) in
            print("APNS Token update on server Respnose Status  = \(status)")
            print("APNS Token update on server Respnose = \(response)")
        }
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any] , appStateForeGround: Bool)
    {
        if KTAppSessionInfo.currentSession.sessionId == nil {
            KTUserManager().loadAppSessionFromDB()
            guard let _ = KTAppSessionInfo.currentSession.sessionId else {
                //If no session then return. 
                return
            }
        }
        print("Notification Recived: \(userInfo)")
        guard let bookingId = userInfo[Constants.NotificationKey.BookingId] else {
            return
        }
        
        //TODO: -Save notification in DB
        KTBookingManager().booking(forBookingID: bookingId as! String) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                
                
                let booking : KTBooking = response[Constants.ResponseAPIKey.Data] as! KTBooking
                
                KTNotificationManager().saveNotificaiton(serverNotification: userInfo, booking: booking)
                
                //TODO: - show alert if application is in foreground.
                if appStateForeGround {
                    
                    self.showAlert(forBooking: booking, userInfo: userInfo)
                    
                    
                    
                    //self.present(alertController, animated: true, completion: nil)
                }
                else {
                (UIApplication.shared.delegate as! AppDelegate).moveToDetailView(withBooking: response[Constants.ResponseAPIKey.Data] as! KTBooking)
                }
            }
        }
        
    }
    
    private func showAlert(forBooking booking : KTBooking, userInfo: [AnyHashable : Any]) {
        
        let alertController = UIAlertController(title: alertTitle(forBooking: booking), message: (userInfo[Constants.NotificationKey.RootNotificationKey] as! [AnyHashable : Any])[Constants.NotificationKey.Message] as? String, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            (UIApplication.shared.delegate as! AppDelegate).moveToDetailView(withBooking: booking)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showAlter(alertController: alertController)
    }
    
    private func alertTitle(forBooking booking : KTBooking) -> String? {
        
        var title : String?
        if booking.bookingStatus == BookingStatus.COMPLETED.rawValue && booking.isRated == false {
            title = "Rate Trip"
        }
        return title
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
