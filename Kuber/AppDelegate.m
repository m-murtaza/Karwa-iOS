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
#import "MagicalRecord+Setup.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "KSBookingDetailsController.h"
#import "KSTripRatingController.h"
#import "AFNetworking.h"
#import "KSConfirmationAlert.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [Fabric with:@[[Crashlytics class]]];

    [self setupGoogleAnalytics];
    
    [self applyUICustomizations];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];

    [self getAPNSToken];

    UIViewController *menuController = [UIStoryboard menuController];
    UIViewController *frontController;

    KSUser *user = [KSDAL loggedInUser];
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

    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, id response) {}];
    [KSDAL syncLocationsWithCompletion:^(KSAPIStatus status, id response) {}];
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {}];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
    [KSDBManager saveContext: NULL];
}

#pragma mark - APNS function

-(void) getAPNSToken
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /*if (![[KSSessionInfo currentSession] pushToken]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }*/
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             | UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSCharacterSet *extraChars = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:extraChars];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSLog(@"Device Token %@",token);
    
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"APNS_Token"];
    [defaults synchronize];*/
    
    [KSSessionInfo updateToken:token];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to get token: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    NSLog(@"%s: %@", __func__, userInfo);
    
    NSString *bookingId = [userInfo objectForKey:@"BookingID"];
    if (!bookingId || [bookingId isEqualToString:@""]) {
        return;
    }
    
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        [self handleNotificaiton:bookingId];
    }
    else
    {
        KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
           [self handleNotificaiton:bookingId];
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
    
    
}

-(void) handleNotificaiton:(NSString*) bookingId
{
    [KSDAL bookingWithBookingId:bookingId
                     completion:^(KSAPIStatus status, id response) {
                         NSLog(@"%@",response);
                         if (KSAPIStatusSuccess == status) {
                             KSTrip *trip = (KSTrip*)response;
                             
                             KSBookingDetailsController *detailController = [UIStoryboard bookingDetailsController];
                             detailController.tripInfo = trip;
                             detailController.isOpenedFromPushNotification = TRUE;
                             
                             SWRevealViewController *swReveal =(SWRevealViewController *) self.window.rootViewController;
                             
                             UINavigationController *navController = (UINavigationController*)swReveal.frontViewController;
                             [navController pushViewController:detailController animated:NO];
                             
                         }
                     }];
}


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


    NSShadow *shadow = [[NSShadow alloc] init];

    shadow.shadowColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    UIColor *navTitleColor = [self colorWithRed:245 green:245 blue:245];
    [appearance setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           navTitleColor, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"MuseoForDell-500" size:21.0], NSFontAttributeName, nil]];
    
    [appearance setTintColor:navTitleColor];

    [appearance setBackIndicatorImage:[UIImage imageNamed:@"backarrow.png"]];
    [appearance setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backarrow.png"]];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    //for Customise font
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"MuseoForDell-300" size:18.0]];

}

-(void) setupGoogleAnalytics
{
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    //gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}

@end
