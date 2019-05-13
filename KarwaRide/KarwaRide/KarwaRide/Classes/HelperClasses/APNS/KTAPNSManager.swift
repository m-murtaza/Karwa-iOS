//
//  KSAPNSManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/21/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationBannerSwift
import AVFoundation

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
    
    func receiveNotification(data: [AnyHashable : Any] , appStateForeGround: Bool)
    {
        if KTAppSessionInfo.currentSession.sessionId == nil {
            KTUserManager().loadAppSessionFromDB()
            guard let _ = KTAppSessionInfo.currentSession.sessionId else {
                //If no session then return. 
                return
            }
        }
        print("Notification Recived: \(data)")
        
        if(data[Constants.NotificationKey.BookingId] != nil)
        {
            let bookingId = data[Constants.NotificationKey.BookingId]
            //TODO: -Save notification in DB
            KTBookingManager().booking(forBookingID: bookingId as! String) { (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS {
                    
                    let booking : KTBooking = response[Constants.ResponseAPIKey.Data] as! KTBooking
                    
                    KTNotificationManager().saveNotificaiton(serverNotification: data, booking: booking)
                    
                    if appStateForeGround
                    {
                        //                    self.showAlert(forBooking: booking, userInfo: userInfo)
                        /* Showing banner instead of pop-up */
                        self.showBanner(forBooking: booking, userInfo: data)
                        (UIApplication.shared.delegate as! AppDelegate).updateViewControllerIfRequired(forBooking: booking)
                    }
                    else
                    {
                        (UIApplication.shared.delegate as! AppDelegate).moveToDetailView(withBooking: response[Constants.ResponseAPIKey.Data] as! KTBooking)
                    }
                }
            }
        }
        
        if(data[Constants.LoginResponseAPIKey.Phone] != nil)
        {
            let responseDic = data as! [String : Any]
            
            guard let phone = responseDic[Constants.LoginResponseAPIKey.Phone] as? String else {
                return
            }
            
//            let predicate : NSPredicate = NSPredicate(format:"phone = %d" , phone)
//            KTUser.mr_deleteAll(matching: predicate)
            
            let user : KTUser = self.loginUserInfo()!
            user.name = responseDic[Constants.EditAccountInfoParam.Name] as? String
            user.email = responseDic[Constants.EditAccountInfoParam.Email] as? String
            user.isEmailVerified = (responseDic[Constants.EditAccountInfoParam.isEmailVerified] as? String) == "True" ? true : false
            
            if let gender = responseDic[Constants.EditAccountInfoParam.gender] as? String, let genderIntVal = Int16(gender) {
                user.gender = genderIntVal
            }
            
            if(!self.isNsnullOrNil(object: responseDic[Constants.EditAccountInfoParam.dob] as AnyObject))
            {
                user.dob = Date.dateFromServerStringWithoutDefault(date: responseDic[Constants.EditAccountInfoParam.dob] as? String)
            }
            
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
        }
    }

    private func showBanner(forBooking booking : KTBooking, userInfo: [AnyHashable : Any])
    {
        let title = alertTitle(forBooking: booking)
        let message = (userInfo[Constants.NotificationKey.RootNotificationKey] as! [AnyHashable : Any])[Constants.NotificationKey.Message] as? String
     
        AudioServicesPlaySystemSound(1307)
        self.showBanner(title ?? "  ", message!, BannerStyle.success)
    }
    
    private func showBanner(_ title: String, _ message: String, _ bannerStyle: BannerStyle)
    {
        let banner = NotificationBanner(title: title, subtitle: message, style: bannerStyle)
        banner.show()
        DispatchQueue.main.asyncAfter(deadline: (.now() + 4))
        {
            banner.dismiss()
        }
    }
    
    private func showAlert(forBooking booking : KTBooking, userInfo: [AnyHashable : Any])
    {
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
    
    func isNsnullOrNil(object : AnyObject?) -> Bool
    {
        if (object is NSNull) || (object == nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func loginUserInfo() -> KTUser? {
        guard NSManagedObjectContext.mr_default() != nil else {
            return nil
        }
        
        var user : KTUser? = nil
        var users: [NSManagedObject]!
        users = KTUser.mr_findAll(in: NSManagedObjectContext.mr_default())
        if users.count > 0 {
            user = users[0] as? KTUser
        }
        return user
    }
}
