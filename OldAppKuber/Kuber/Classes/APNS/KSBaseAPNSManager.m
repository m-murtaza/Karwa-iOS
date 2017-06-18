//
//  BaseAPNSManager.m
//  Kuber
//
//  Created by Muhammad Usman on 4/20/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSBaseAPNSManager.h"

@implementation KSBaseAPNSManager


//Abstract function
-(void) registerForRemoteNotification
{
//    if (![[KSSessionInfo currentSession] pushToken])
//    {
        [self registerNotification];
//    }
}

-(void) registerNotification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(void) handleNotificationForAppliactionState:(BOOL)appInBackGround BookingID:(NSString*) bookingId UserInfo:(NSDictionary*)userinfo
{
    if (!bookingId || [bookingId isEqualToString:@""] || (NSNull*)bookingId == [NSNull null] || [bookingId isEqualToString:@"null"]) {
        //Sub chk kar lo .....
        DLog("unable to find booking ID");
        return;
    }
    
    [KSDAL bookingWithBookingId:bookingId
                     completion:^(KSAPIStatus status, id response) {
                         if (KSAPIStatusSuccess == status && response != nil) {
                             
                             KSTrip *trip = (KSTrip*) response;
                             //trip.status = [NSNumber numberWithInt:KSTripStatusComplete];
                             trip.rating = nil;
                             
                             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                             [appDelegate updateUIForNotification:userinfo Trip:trip AppState:appInBackGround];
                             
//                             if (appInBackGround) {
//                                 
//                                 //[self navigateToBookingDetailsForTrip:trip];
//                             }
//                             else{
//                                 //[self showAlertForTrip:trip UserInfo:userinfo];
//                             }
                             
                         }
                     }];
    
}


#pragma mark - APNS Delegates
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSCharacterSet *extraChars = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:extraChars];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Device Token %@",token);
    
    if(![token isEqualToString:[[KSSessionInfo currentSession] pushToken]])
    {
        //If old token is not equals the new one. 
        [KSSessionInfo updateToken:token];
        
        if ([[KSSessionInfo currentSession] sessionId]) {
            [KSDAL updateUserWithPushToken:token completion:^(KSAPIStatus status, id response) {
                
                if (status == KSAPIStatusSuccess) {
                    
                    NSLog(@"Push Token updated successfully");
                }
                else{
                    
                    NSLog(@"Push token not updated");
                }
            }];
        }
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to get token: %@", error);
}
@end
