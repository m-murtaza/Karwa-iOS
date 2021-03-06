//
//  KSDAL.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+User.h"

#import "KSDBManager.h"
#import "KSWebClient.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation KSDAL (KSUser)

#pragma mark -
#pragma mark - User management

+ (void)logoutUser {

    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:@"/user/logout" params:nil completion:^(BOOL success, NSDictionary *response) {
        // Do nothing
        [KSDAL removeSyncTime];
        [KSDAL removeAllBookings];
    }];
    // Remove session info from client, any how
    [KSSessionInfo removeSession];
}

+ (KSUser *)userWithPhone:(NSString *)phone {
    return [KSUser objWithValue:phone forAttrib:@"phone"];
}

+ (void)registerUser:(KSUser *)user password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = @{
        @"Phone": user.phone,
        @"Name": user.name,
        @"Email": user.email,
        @"Password": [password MD5]
    };

    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:@"/user" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {
                // Save user
                [KSDBManager saveContext:^{
                    completionBlock(status, nil);
                }];
            }
            else {
                completionBlock(status, nil);
            }
        }
    }];
}

/*
    This method is used for login and OTP verification requests
 */
+ (void)sendLoginRequestViaUri:(NSString *)uri withPhone:(NSString *)phone data:(NSDictionary *)requestData completion:(KSDALCompletionBlock)completionBlock {

    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithDictionary:requestData];
    postData[@"Phone"] = phone;
#if (TARGET_IPHONE_SIMULATOR)
    postData[@"DeviceType"] = @1;
    postData[@"DeviceToken"] = @"1234567891234567891234567891234567891234";
#else
    postData[@"DeviceType"] = @1;
    if([[KSSessionInfo currentSession] pushToken]){
        
        postData[@"DeviceToken"] = [[KSSessionInfo currentSession] pushToken];
    }

#endif
    
    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:uri data:postData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {
                NSDictionary *userInfo = response[@"data"];
                // Create new user in local DB
                KSUser *user = [KSDAL userWithPhone:userInfo[@"Phone"]];
                user.email = userInfo[@"Email"];
                user.name = userInfo[@"Name"];
                if(userInfo[@"CustomerType"])
                    user.customerType = userInfo[@"CustomerType"];
                else
                    user.customerType = [NSNumber numberWithInteger:0];
                [KSDBManager saveContext:^{
                    completionBlock(status, nil);
                }];
                
                [KSSessionInfo updateSession:userInfo[@"SessionID"] phone:userInfo[@"Phone"] customerType:user.customerType];
            }
            else {
                completionBlock(status, nil);
            }
        }
    }];

}

+ (void)loginUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {

    [self sendLoginRequestViaUri:@"/user/login" withPhone:phone data:@{@"Password": password.MD5} completion:completionBlock];
}

+ (void)verifyUserWithPhone:(NSString *)phone code:(NSString *)accessCode completion:(KSDALCompletionBlock)completionBlock {

    [self sendLoginRequestViaUri:@"/user/otp" withPhone:phone data:@{@"Otp": accessCode} completion:completionBlock];
}

+ (void)sendOtpOnPhone:(NSString *)phone completion:(KSDALCompletionBlock)completionBlock {
    
    KSWebClient *webClient = [KSWebClient instance];
    NSString *uri = [NSString stringWithFormat:@"/user/otp/%@", phone];
    [webClient GET:uri params:nil completion:^(BOOL success, NSDictionary *response) {

        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        completionBlock(status, nil);
    }];
}

+ (void)resetPasswordForUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = @{
          @"Phone": phone,
          @"Password": [password MD5]
    };

    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/user/pwd" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            completionBlock(status, nil);
        }
    }];
}

+ (void)updateUserInfoWithData:(NSDictionary *)requestData completion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/user/update" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {

                KSUser *user = [KSDAL loggedInUser];//[self userWithPhone:requestData[@"Phone"]];
                if (requestData[@"Email"]) {
                    user.email = requestData[@"Email"];
                }
                if (requestData[@"Name"]) {
                    user.name = requestData[@"Name"];
                }
                [KSDBManager saveContext:^{
                    NSArray *a = [KSDAL allUser];
                    for (KSUser *u in a) {
                        NSLog(@"%@",u);
                    }
                    completionBlock(status, nil);
                }];
            }
            else {
                completionBlock(status, nil);
            }
        }
    }];
}

+ (void)updateUserInfoWithEmail:(NSString *)email withName:(NSString *)userName completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = @{@"Name": userName, @"Email": email};

    [self updateUserInfoWithData:requestData completion:completionBlock];
}

+ (void)updateUserPassword:(NSString *)oldPassword withPassword:(NSString *)newPassword completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = @{
                                  @"Password": [oldPassword MD5],
                                  @"NewPassword": [newPassword MD5]
                                  };
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

+(void)updateUserWithPushToken:(NSString*)pushToken completion:(KSDALCompletionBlock)completionBlock{
   NSDictionary *requestData = @{@"DeviceToken": pushToken};
    
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

@end
