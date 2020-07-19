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
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var location :KTLocationManager?
    var currentViewControllerName: KTBaseViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AppVersionUpdateNotifier().initNotifier(self)
        
        setupDatabase()
        fetchInitialApplicationDataIfNeeded()
        handleNotification(launchOptions: launchOptions)
        
        updateUIAppreance()
        setupLocation()
        setupGoogleMaps()
        
        //register For APNS if needed
        registerForPushNotifications()
        
        setupFirebase()
        
        return true
    }
    
    func setupFirebase()
    {
        #if DEBUG || ADHOC
        print("Skipping Firebase because of debug build")
        #else
        print("Initializing K-Firebase")
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self()])
        Fabric.sharedSDK().debug = true
        setFirebaseAnalyticsUserPref()
        #endif
    }
    
    func setFirebaseAnalyticsUserPref()
    {
        guard let user:KTUser = KTUserManager().loginUserInfo() else
        {
            return
        }

        Analytics.setUserID((user.name != nil) ? (user.phone!) : "No Phone")
        Analytics.setUserProperty((user.name != nil) ? (user.phone!) : "No Phone", forName: "Phone")
        Analytics.setUserProperty((user.name != nil) ? (user.name!) : "No Name", forName: "Name")
        Analytics.setUserProperty((user.email != nil) ? (user.email!) : "No Email", forName: "Email")
        Analytics.setUserProperty(String(user.customerType), forName: "Customer-Type")
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
    
    func fetchInitialApplicationDataIfNeeded() {
        SharedPrefUtil.resetRideIfRequired()
        KTVehicleTypeManager().fetchInitialTariffLocal()
        KTCancelBookingManager().fetchInitialCancelReasonsLocal()
        KTRatingManager().fetchInitialRatingReasonsLocal()
    }
    
    func setupDatabase()  {
        
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "Karwa")
//        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.error)
    }
    
    func setupLocation() {
        location = KTLocationManager.sharedInstance
        location?.setUp()
        location?.start()
    }
    
    func setupGoogleMaps() {
        
        GMSServices.provideAPIKey(Constants.GOOGLE_DIRECTION_API_KEY)
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else
        {
            return false
        }

        let pathsComing = components.path

        let tripServerBean = KTUtils.isValidQRCode(pathsComing)
        let trackTripId = KTUtils.isValidTrackTripCode(pathsComing)

        if(tripServerBean != nil)
        {
            moveToPaymentViewIfRequired(tripServerBean)
        }
        else if(trackTripId != nil && (trackTripId ?? "").length > 0)
        {
            let trackTripId = KTUtils.isValidTrackTripCode(pathsComing)
            if(trackTripId != nil)
            {
                moveToTrackTripViewIfRequired(trackTripId)
            }
        }
        
        return true
    }
    
    
    
    /* Present Pay Trip View Controller */
    func presentTripPayViewController(_ payTrip: PayTripBeanForServer)
    {
        //TODO: Show Pay View Controller
//        let sBoard = UIStoryboard(name: "Main", bundle: nil)
//        let detailView : KTPaymentViewController = sBoard.instantiateViewController(withIdentifier: "KTPaymentViewControllerIdentifier") as! KTPaymentViewController
//        detailView.isManageButtonPressed = true
//        self.showView(view: detailView)
        
//                let sBoard = UIStoryboard(name: "Main", bundle: nil)
//                let detailView : KTCreateBookingViewController = sBoard.instantiateViewController(withIdentifier: "BookingStep1") as! KTCreateBookingViewController
//                detailView.showPayment()
        
    }
    
    //Notifiacation receive when application is in background
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        if (application.applicationState == .active)
        {
            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
//            print("==================================================")
//            print("Notification Arrived in Active State")
//            print("==================================================")
        }
        else
        {
//            print("==================================================")
//            print("Notification Arrived in In-Active State")
//            print("==================================================")
        }

        apnsManager.receiveNotification(data: userInfo, appStateForeGround: true)
    }

    func handleNotification(launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    {
//        print("==================================================")
//        print("Notification Arrived in Handle Notification")
//        print("==================================================")
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
        {
            let aps = notification["aps"] as! [String: AnyObject]
            print(aps)
            apnsManager.receiveNotification(data: aps, appStateForeGround: false)
        }
    }
    
    func moveToDetailView(withBooking booking: KTBooking) {
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
        let contentView : UINavigationController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.DetailView) as! UINavigationController
        
        let detailView : KTBookingDetailsViewController = (contentView.viewControllers)[0] as! KTBookingDetailsViewController
        detailView.setBooking(booking: booking)
        detailView.isOpenFromNotification = true
        self.showView(view: detailView)
        
    }
    
    func moveToTrackTripViewIfRequired(_ trackTripId: String?)
    {
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
        let contentView : UINavigationController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.TrackTripNavController) as! UINavigationController
        
        let ktPaymentViewController : KTTrackTripViewController = (contentView.viewControllers)[0] as! KTTrackTripViewController

        if(trackTripId != nil)
        {
            ktPaymentViewController.trackTripId = trackTripId!
            self.showView(view: ktPaymentViewController)
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75)
            {
                ktPaymentViewController.showErrorBanner("  ", "Invalid Track Trip Code ")
            }
        }
    }
    
    func moveToPaymentViewIfRequired(_ payTripBean: PayTripBeanForServer?)
    {
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
        let paymentNavigationController : UINavigationController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.PaymentNavigationController) as! UINavigationController
        let ktPaymentViewController : KTPaymentViewController = (paymentNavigationController.viewControllers)[0] as! KTPaymentViewController
        
        if(payTripBean != nil)
        {
            ktPaymentViewController.payTripBean = payTripBean
            ktPaymentViewController.isManageButtonPressed = true
            ktPaymentViewController.isTriggeredFromUniversalLink = true
            
            let leftView : UIViewController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.LeftMenu)
            let sideMeun : SSASideMenu = SSASideMenu(contentViewController: paymentNavigationController, leftMenuViewController: leftView)
            
            window? = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = sideMeun
            window?.makeKeyAndVisible()
            
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75)
            {
                ktPaymentViewController.showErrorBanner("  ", "Invalid QR Code ")
            }
        }
    }
    
    func showLogin()  {
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
        let contentView : UIViewController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.LoginView)
        self.showView(view: contentView)
    }
    
    func showView(view: UIViewController) {
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
//        let contentView : UIViewController = sBoard.instantiateViewController(withIdentifier: storyBoardId)
        let leftView : UIViewController = sBoard.instantiateViewController(withIdentifier: Constants.StoryBoardId.LeftMenu)
        let sideMeun : SSASideMenu = SSASideMenu(contentViewController: view, leftMenuViewController: leftView)
        
        window? = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = sideMeun
        window?.makeKeyAndVisible()
    }
    
    
    //MARK: - Alert
    func showAlter(alertController : UIAlertController) {
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func getCurrentViewControllerName() -> String
    {
        if(currentViewControllerName != nil)
        {
            return NSStringFromClass(currentViewControllerName!.classForCoder)
        }
        else
        {
            return ""
        }
    }
    
    func setCurrentViewController(_ controller: KTBaseViewController?)
    {
        if(controller == nil)
        {
            currentViewControllerName = nil
        }
        else
        {
            currentViewControllerName = controller
        }
    }
    
    func updateViewControllerIfRequired(forBooking booking : KTBooking)
    {
        if(getCurrentViewControllerName() == "KarwaRide.KTBookingDetailsViewController" || getCurrentViewControllerName() == "KarwaRide.KTMyTripsViewController")
        {
            currentViewControllerName?.updateForBooking(booking)
        }
    }
}


extension AppDelegate: AppUpdateNotifier {
    func onVersionUpdate(newVersion: Int, oldVersion: Int) {
        resetSyncTime(forKey: INIT_TARIFF_SYNC_TIME)
    }

    func resetSyncTime(forKey key: String) {
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(Date(timeIntervalSince1970: 0), forKey: key)
        defaults?.synchronize()
    }

    func onFirstLaunch() {
        //do something
    }
}
