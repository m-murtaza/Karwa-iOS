//
//  KSiOS9APNS.m
//  Kuber
//
//  Created by Muhammad Usman on 4/20/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSiOS9APNS.h"

@implementation KSiOS9APNS
-(void) registerNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:settings];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

-(void) handleNotificaiton:(NSString*) bookingId UserInfo:(NSDictionary*)userinfo
{
    DLog("Handle notification");
    BOOL appInBackGround = FALSE;
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        appInBackGround = TRUE;
    }
    //[self handleNotificationForAppliactionState:appInBackGround BookingID:bookingId UserInfo:userinfo];
    
    
    [self handleNotificationForAppliactionState:appInBackGround BookingID:bookingId UserInfo:userinfo];
    }

@end
