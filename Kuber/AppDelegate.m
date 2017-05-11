//
//  AppDelegate.m
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "KSDBManager.h"
#import "SWRevealViewController.h"
#import <MagicalRecord/MagicalRecord+Setup.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "KSBookingDetailsController.h"
#import "KSTripRatingController.h"
#import "AFNetworking.h"
#import "KSConfirmationAlert.h"

#import "KSiOS10APNS.h"
#import "KSiOS9APNS.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@property (nonatomic, strong) KSBaseAPNSManager *apnsManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Limo coachmarks will display only when application run first time after update to version 1.4
    [self setFlagForLimoCoachMarks];
    
   //[self testFunc];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [Fabric with:@[[Crashlytics class]]];

    [self setupGoogleAnalytics];
    
    [self applyUICustomizations];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    KSUser *user = [KSDAL loggedInUser];

    [self registerForRemoteNotification];

    UIViewController *menuController = [UIStoryboard menuController];
    UIViewController *frontController;

   //KSUser *user = [KSDAL loggedInUser];
    // TODO: Think of validation session
//    user = nil;
    if (user) {
        frontController = [UIStoryboard mainRootController];
    }
    else {
        frontController = [UIStoryboard loginRootController];
    }

    SWRevealViewController *rootController = [[SWRevealViewController alloc] initWithRearViewController:menuController frontViewController:frontController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    return YES;
}

-(void) setFlagForLimoCoachMarks
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:@"KSDeviceToken"];
    if(token != nil)
    {
        //Application is not new installation, KSDeviceToken have nothing to do with limocoachmarks, just using it to identify if applicaiton is fresh install(not update) or old one.
        if(![((NSNumber*)[defaults valueForKey:KSTaxiLimoDefaultKey]) boolValue])
        {
            //User havn't view Taxi limo coachmark.
            [defaults setValue:[NSNumber numberWithBool:false] forKey:KSTaxiLimoDefaultKey];
            [defaults synchronize];
        }
        
        if(![((NSNumber*)[defaults valueForKey:KSLimoTypeDefaultKey]) boolValue])
        {
            //User havn't view Taxi limo coachmark.
            [defaults setValue:[NSNumber numberWithBool:false] forKey:KSLimoTypeDefaultKey];
            [defaults synchronize];
        }
    }
    else
    {
        [defaults setValue:[NSNumber numberWithBool:true] forKey:KSTaxiLimoDefaultKey];
        [defaults setValue:[NSNumber numberWithBool:true] forKey:KSLimoTypeDefaultKey];
        [defaults synchronize];
    }
}

-(void) showLoginScreen
{
    UIViewController *menuController = [UIStoryboard menuController];
    UIViewController *frontController = [UIStoryboard loginRootController];
    SWRevealViewController *rootController = [[SWRevealViewController alloc] initWithRearViewController:menuController frontViewController:frontController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
}

/*-(void) testFunc
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*\bWWWWW.*" options:0 error:NULL];
    NSString *str = @"stackoverflow.html";
    str = @"abcd";
    NSTextCheckingResult *match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    // [match rangeAtIndex:1] gives the range of the group in parentheses
    // [str substringWithRange:[match rangeAtIndex:1]] gives the first captured group in this example
    
    NSLog(@"%@",[str substringWithRange:[match rangeAtIndex:1]]);
}*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, id response) {
        [KSDAL removeOldBookings];
    }];
    
    //Removed after discussing with Asif Kamboh, Now reverse goecode implementation will be on server side. 
    //[KSDAL syncLocationsWithCompletion:^(KSAPIStatus status, id response) {}];
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {}];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
    [KSDBManager saveContext: NULL];
}

#pragma mark - APNS function

// This is initial function for APNS to fethc device token.
-(void) registerForRemoteNotification
{
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        _apnsManager = [[KSiOS10APNS alloc] init];
        
    }
    else
        _apnsManager = [[KSiOS9APNS alloc] init];
    
    [_apnsManager registerForRemoteNotification];
}

//Device token delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [_apnsManager application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}



- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [_apnsManager application:application didFailToRegisterForRemoteNotificationsWithError:error];
}


#pragma mark - iOS 9 APNS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [_apnsManager application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark - UI Action on Notification 

-(void) updateUIForNotification:(NSDictionary*)userinfo Trip:(KSTrip*) trip AppState:(bool)appInBackGround
{
     if (appInBackGround) {

         [self navigateToBookingDetailsForTrip:trip];
     }
     else {
        
         [self showAlertForTrip:trip UserInfo:userinfo];
     }

}

-(void) navigateToBookingDetailsForTrip:(KSTrip*)trip
{
    
    KSBookingDetailsController *detailController = [UIStoryboard bookingDetailsController];
    detailController.tripInfo = trip;
    detailController.isOpenedFromPushNotification = TRUE;
    
    //KSBookingMapController *mapController = [UIStoryboard bookingMapController];
    
    
    SWRevealViewController *swReveal =(SWRevealViewController *) self.window.rootViewController;
    
    UINavigationController *navController = (UINavigationController*)swReveal.frontViewController;
    [navController pushViewController:detailController animated:NO];
    //[detailController hideLoadingView];
}

-(void) showAlertForTrip:(KSTrip*)trip UserInfo:(NSDictionary*)userInfo
{
    
    NSString *okBtnTitle = @"Details";
    if ([trip.status integerValue] == KSTripStatusComplete && trip.rating == nil) {
        okBtnTitle = @"Rate Trip";
    }
    
    KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:okBtnTitle handler:^(KSConfirmationAlertAction *action) {
        [self navigateToBookingDetailsForTrip:trip];
    }];
    KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel"
                                                                                 handler:^(KSConfirmationAlertAction *action) {
                                                                                     
                                                                                 }];
    NSString *message = nil;
    NSDictionary *alert = [userInfo objectForKey:@"aps"];
    if (alert) {
        message = [alert objectForKey:@"alert"];
    }
    if (message) {
        
        [KSConfirmationAlert showWithTitle:@"Notification"
                                   message:message
                                  okAction:okAction
                              cancelAction:cancelAction];
    }
}


#pragma mark - UI Customization for App
- (UIColor *)colorWithRed:(int)r green:(int)g blue:(int)b {
    
    return [UIColor colorWithRed:(CGFloat)r / 255.0
                           green:(CGFloat)g / 255.0
                            blue:(CGFloat)b / 255.0
                           alpha:1.0];
}

- (void)applyUICustomizations {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationBar *appearance = [UINavigationBar appearance];
    
    UIColor *navBarColor = [self colorWithRed:24.0 green:122.0 blue:137.0];
    [appearance setBarTintColor:navBarColor];
    if(IS_IOS8)
        [appearance setTranslucent:FALSE];


    /*NSShadow *shadow = [[NSShadow alloc] init];

    shadow.shadowColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    */
    
    
    UIColor *navTitleColor = [self colorWithRed:245 green:245 blue:245];
    [appearance setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           navTitleColor, NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"MuseoForDell-500" size:21.0], NSFontAttributeName, nil]];
    
    [appearance setTintColor:[UIColor colorFromHexString:@"#21d7d7"]];

   [appearance setBackIndicatorImage:[UIImage imageNamed:@"backarrow.png"]];
    [appearance setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backarrow.png"]];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    //for Customise font
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"MuseoForDell-300" size:18.0]];
     

}

#pragma mark - Google Analytics
-(void) setupGoogleAnalytics
{
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    //gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
    
    
    [[GAI sharedInstance] setDryRun:NO];
    
}

@end
