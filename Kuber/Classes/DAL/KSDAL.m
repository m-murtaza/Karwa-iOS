//
//  KSDAL.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL.h"

#import "KSDBManager.h"
#import "KSWebClient.h"

#import "KSUser.h"
#import "KSTrip.h"

#import "KSSessionInfo.h"
#import "CoreData+MagicalRecord.h"

@implementation KSDAL

+ (void)saveLoggedInUserSession:(NSString *)sessionId phone:(NSString *)phone {
    [KSSessionInfo updateSession:sessionId phone:phone];
}

+ (KSUser *)loggedInUser {
    KSUser *user = nil;
    KSSessionInfo* sessionInfo = [KSSessionInfo currentSession];
    // No need to fetch user if the session ID is not stored
    if (sessionInfo.sessionId) {
        user = [KSUser MR_findFirstByAttribute:@"phone" withValue:sessionInfo.phone];
    }
    return user;
}

+ (void)logoutUser {
    [KSSessionInfo removeSession];
}

+ (KSUser *)userWithPhone:(NSString *)phone {
    return [KSUser objWithValue:phone forAttrib:@"phone"];
}

+ (KSAPIStatus)statusFromResponse:(NSDictionary *)response success:(BOOL)success {
    KSAPIStatus status = KSAPIStatusUnknownError;
    if (success) {
        status = [response[@"status"] unsignedIntegerValue];
    }
    return status;
}

+ (void)registerUser:(KSUser *)user password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = @{
        @"phone": user.phone,
        @"name": user.name,
        @"email": user.email,
        @"password": [password MD5]
    };

    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:@"/register" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {
                // Save user
                [KSDBManager saveContext];
            }
            completionBlock(status, nil);
        }
    }];
}

/*
    This method is used for login and OTP verification requests
 */
+ (void)sendLoginRequesViaUri:(NSString *)uri data:(NSDictionary *)requestData completion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:uri data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {
                NSDictionary *userInfo = response[@"data"];
                // Create new user in local DB
                KSUser *user = [KSDAL userWithPhone:userInfo[@"phone"]];
                user.email = userInfo[@"email"];
                user.name = userInfo[@"name"];
                [KSDBManager saveContext];
                
                [KSSessionInfo updateSession:userInfo[@"sid"] phone:userInfo[@"phone"]];
            }
            completionBlock(status, nil);
        }
    }];

}

+ (void)loginUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {
    NSDictionary *requestData = @{
      @"phone": phone,
      @"token": [[KSSessionInfo currentSession] pushToken],
      @"password": [password MD5]
    };
    [self sendLoginRequesViaUri:@"/login" data:requestData completion:completionBlock];
}

+ (void)verifyUserWithPhone:(NSString *)phone code:(NSString *)accessCode completion:(KSDALCompletionBlock)completionBlock {
    NSDictionary *requestData =
  @{
      @"phone": phone,
      @"token": [[KSSessionInfo currentSession] pushToken],
      @"otp": accessCode
    };
    [self sendLoginRequesViaUri:@"/verify" data:requestData completion:completionBlock];
}

+ (void)resetPasswordForUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {
    NSDictionary *requestData = @{
          @"phone": phone,
          @"password": [password MD5]
    };

    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/resetpwd" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            completionBlock(status, nil);
        }
    }];
}

+ (void)updateUserInfoWithData:(NSDictionary *)requestData completion:(KSDALCompletionBlock)completionBlock {
    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/edituser" data:requestData completion:^(BOOL success, NSDictionary *response) {
        if (completionBlock) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if (KSAPIStatusSuccess == status) {
                NSDictionary *userInfo = response[@"data"];
                KSUser *user = [self userWithPhone:requestData[@"phone"]];
                if (requestData[@"email"]) {
                    user.email = requestData[@"email"];
                }
                if (requestData[@"name"]) {
                    user.name = requestData[@"name"];
                }
                [KSDBManager saveContext];
                // Update session ID
                if (requestData[@"new_password"] && ![requestData[@"sid"] isEqualToString:userInfo[@"sid"]]) {
                    [KSSessionInfo updateSession:userInfo[@"sid"] phone:requestData[@"phone"]];
                }
            }
            completionBlock(status, nil);
        }
    }];
}

+ (NSDictionary *)authenticateRequestData:(NSDictionary *)requestData {

    NSMutableDictionary *resultData = [NSMutableDictionary dictionaryWithDictionary:requestData];
    KSSessionInfo *sessionInfo = [KSSessionInfo currentSession];
    resultData[@"phone"] = sessionInfo.phone;
    resultData[@"sid"] = sessionInfo.sessionId;
    return [NSDictionary dictionaryWithDictionary:resultData];
}

+ (void)updateUserInfoWithEmail:(NSString *)email withName:(NSString *)userName completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{@"name": userName, @"email": email}];
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

+ (void)updateUserPassword:(NSString *)oldPassword withPassword:(NSString *)newPassword completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{@"password": [oldPassword MD5],
                                                               @"new_password": [newPassword MD5]}];
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon {

    KSTrip *trip = [KSDBManager tripWithLandmark:landmark lat:lat lon:lon];
    trip.passenger = [self loggedInUser];

    return trip;
}

+ (void)bookTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock {
    KSSessionInfo *sessionInfo = [KSSessionInfo currentSession];

    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];

    [requestData setObject:[NSNumber numberWithInteger:1] forKey:@"taxi_type"];
    [requestData setObjectOrNothing:sessionInfo.pushToken forKey:@"token"];
    [requestData setObjectOrNothing:trip.pickupLandmark forKey:@"landmark"];
    [requestData setObjectOrNothing:trip.pickupLat forKey:@"lat"];
    [requestData setObjectOrNothing:trip.pickupLon forKey:@"lon"];
    [requestData setObjectOrNothing:trip.pickupTime forKey:@"pick_time"];
    [requestData setObjectOrNothing:trip.dropOffLat forKey:@"drop_lat"];
    [requestData setObjectOrNothing:trip.dropOffLon forKey:@"drop_lon"];
    [requestData setObjectOrNothing:trip.dropoffLandmark forKey:@"drop_landmark"];
    
    NSDictionary *authenticatedRequestData = [self authenticateRequestData:requestData];

    KSWebClient *webClient = [KSWebClient instance];
    __block KSTrip *tripInfo = trip;
    [webClient POST:@"/booking" data:authenticatedRequestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            tripInfo.jobId = response[@"job_id"];
            tripInfo.status = [NSNumber numberWithInteger:[response[@"status"] integerValue]];
            tripInfo.pickupLat = [NSNumber numberWithInteger:[response[@"lat"] integerValue]];
            tripInfo.pickupLon = [NSNumber numberWithInteger:[response[@"lon"] integerValue]];

            [KSDBManager saveContext];
        } else {
            [tripInfo MR_deleteEntity];
        }
        completionBlock(status, nil);
    }];

}

+ (void)geocodeWithParams:(NSDictionary *)params completion:(KSDALCompletionBlock)completionBlock {
    KSWebClient *webClient = [KSWebClient instance];
    NSDictionary *requestData = [self authenticateRequestData:params];
    [webClient GET:@"/geocode" params:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            completionBlock(status, response);
        }
        else {
            completionBlock(status, nil);
        }
    }];
}

@end
