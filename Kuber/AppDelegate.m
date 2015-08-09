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
#import "KSDAL.h"
#import "KSSessionInfo.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self applyUICustomizations];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];

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

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
    [KSDBManager saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSCharacterSet *extraChars = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:extraChars];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    [KSSessionInfo updateToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to get token: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    NSLog(@"%s: %@", __func__, userInfo);
}


- (UIColor *)colorWithRed:(int)r green:(int)g blue:(int)b {
    
    return [UIColor colorWithRed:(CGFloat)r / 255.0
                           green:(CGFloat)g / 255.0
                            blue:(CGFloat)b / 255.0
                           alpha:1.0];
}

- (void)applyUICustomizations {
    
    UINavigationBar *appearance = [UINavigationBar appearance];
    UIColor *navBarColor = [self colorWithRed:24 green:122 blue:137];
    [appearance setBarTintColor:navBarColor];

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

}

@end
