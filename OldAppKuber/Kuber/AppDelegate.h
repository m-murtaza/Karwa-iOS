//
//  AppDelegate.h
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
#import "KSTrip.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void) updateUIForNotification:(NSDictionary*)userinfo Trip:(KSTrip*) trip AppState:(bool)appInBackGround;

-(void) showLoginScreen;

-(void) navigateToBookingDetailsForTrip:(KSTrip*)trip;

@end

