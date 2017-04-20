//
//  BaseAPNSManager.h
//  Kuber
//
//  Created by Muhammad Usman on 4/20/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>     

@interface KSBaseAPNSManager : NSObject <UNUserNotificationCenterDelegate>

//Abstract function
-(void) registerForRemoteNotification;

-(void) handleNotificationForAppliactionState:(BOOL)appInBackGround BookingID:(NSString*) bookingId UserInfo:(NSDictionary*)userinfo;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
@end
