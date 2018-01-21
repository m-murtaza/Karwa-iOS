//
//  AppDelegate.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/18/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import UserNotifications
import MagicalRecord
import GoogleMaps
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var location :KTLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            print(aps)
            apnsManager.receiveNotification(userInfo: aps)
        }
        else
        {
            //register For APNS if needed
            registerForPushNotifications()
        }

        MagicalRecord.setupCoreDataStack(withStoreNamed: "Karwa")
        
        updateUIAppreance()
        
        location = KTLocationManager.sharedInstance
        location?.setUp()
        
        GMSServices.provideAPIKey("AIzaSyBWEik2kFj1hYESIhS2GgUblo_amSfjqT0")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        AppEventsLogger.activate(application)
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK: UI Appreance
    private func updateUIAppreance ()
    {
        //printFonts()
        let appearance : UINavigationBar = UINavigationBar.appearance()
        
        appearance.barTintColor = UIColor(hexString:"#E5F5F2")
        UIBarButtonItem.appearance().tintColor = UIColor(hexString:"#129793")
        appearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#129793"),
        NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-500", size: 18.0)!]
        
        let backImage = UIImage(named: "BackButton");
        appearance.backIndicatorImage = backImage
        appearance.backIndicatorTransitionMaskImage = backImage
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName )
            print("Font Names = [\(names)]")
        }
    }
    
    // MARK: APPLE PUSH NOTIFICATION
    private let apnsManager : KTAPNSManager = KTAPNSManager.init()
    
    func registerForPushNotifications() {
        apnsManager.registerForPushNotifications()
    }
    
    //delegate device token success
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        apnsManager.deviceTokenReceived(deviceToken: deviceToken)
    }
    
    //delegate device token fail
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    //Notifiacation receive when application is in background
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        apnsManager.receiveNotification(userInfo: userInfo)
        
    }
    
}

