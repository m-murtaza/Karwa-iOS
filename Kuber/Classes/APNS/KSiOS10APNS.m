//
//  iOS10APNS.m
//  Kuber
//
//  Created by Muhammad Usman on 4/20/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSiOS10APNS.h"

@implementation KSiOS10APNS

-(void) registerNotification
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if( !error ){
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }];
}

//Notification delegate when applicaiton is open.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    DLog(@"Notification when application is open - User Info = %@",notification.request.content.userInfo);
    NSString *bookingId = [notification.request.content.userInfo objectForKey:@"BookingID"];
    
    
    [self handleNotificationForAppliactionState:FALSE BookingID:bookingId UserInfo:notification.request.content.userInfo];
    completionHandler(UNNotificationPresentationOptionNone);
}


//Notification delegate when application is close or when tap on notification from notification bar.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"Notification when applicaiton is close - User Info = %@",response.notification.request.content.userInfo);
    
    NSString *bookingId = [response.notification.request.content.userInfo objectForKey:@"BookingID"];
    
    [self handleNotificationForAppliactionState:TRUE BookingID:bookingId UserInfo:response.notification.request.content.userInfo];
    
    completionHandler();
}


@end
