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
#import "KSTripRating.h"
#import "KSBookmark.h"

#import "KSSessionInfo.h"
#import "CoreData+MagicalRecord.h"


@implementation KSDAL

#pragma mark -
#pragma mark - Helpers

+ (KSAPIStatus)statusFromResponse:(NSDictionary *)response success:(BOOL)success {

    KSAPIStatus status = KSAPIStatusUnknownError;
    if (success) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            status = [response[@"status"] unsignedIntegerValue];
        }
        else if ([response isKindOfClass:[NSArray class]]) {
            status = KSAPIStatusSuccess;
        }
    }
    return status;
}

#pragma mark -
#pragma mark - User management

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

    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:@"/user/logout" params:nil completion:^(BOOL success, NSDictionary *response) {
        // Do nothing
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
                [KSDBManager saveContext];
            }
            completionBlock(status, nil);
        }
    }];
}

/*
    This method is used for login and OTP verification requests
 */
+ (void)sendLoginRequesViaUri:(NSString *)uri withPhone:(NSString *)phone data:(NSDictionary *)requestData completion:(KSDALCompletionBlock)completionBlock {

    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithDictionary:requestData];
    postData[@"Phone"] = phone;
    postData[@"DeviceType"] = @1;
    postData[@"DeviceToken"] = [[KSSessionInfo currentSession] pushToken];

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
                [KSDBManager saveContext];
                
                [KSSessionInfo updateSession:userInfo[@"SessionID"] phone:userInfo[@"Phone"]];
            }
            completionBlock(status, nil);
        }
    }];

}

+ (void)loginUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock {

    [self sendLoginRequesViaUri:@"/user/login" withPhone:phone data:@{@"Password": password.MD5} completion:completionBlock];
}

+ (void)verifyUserWithPhone:(NSString *)phone code:(NSString *)accessCode completion:(KSDALCompletionBlock)completionBlock {

    [self sendLoginRequesViaUri:@"/user/otp" withPhone:phone data:@{@"Otp": accessCode} completion:completionBlock];
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
                NSDictionary *userInfo = response[@"data"];
                KSUser *user = [self userWithPhone:requestData[@"Phone"]];
                if (requestData[@"Email"]) {
                    user.email = requestData[@"Email"];
                }
                if (requestData[@"Name"]) {
                    user.name = requestData[@"Name"];
                }
                [KSDBManager saveContext];
            }
            completionBlock(status, nil);
        }
    }];
}

+ (NSDictionary *)authenticateRequestData:(NSDictionary *)requestData {

    NSMutableDictionary *resultData = [NSMutableDictionary dictionaryWithDictionary:requestData];
    KSSessionInfo *sessionInfo = [KSSessionInfo currentSession];
    resultData[@"Phone"] = sessionInfo.phone;
    return [NSDictionary dictionaryWithDictionary:resultData];
}

+ (void)updateUserInfoWithEmail:(NSString *)email withName:(NSString *)userName completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{@"Name": userName, @"Email": email}];
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

+ (void)updateUserPassword:(NSString *)oldPassword withPassword:(NSString *)newPassword completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{@"Password": [oldPassword MD5],
                                                               @"NewPassword": [newPassword MD5]}];
    [self updateUserInfoWithData:requestData completion:completionBlock];
}

#pragma mark -
#pragma mark - Trip management

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
    [webClient POST:@"/bookings/add" data:authenticatedRequestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            tripInfo.jobId = response[@"job_id"];
            tripInfo.status = [NSNumber numberWithInteger:[response[@"status"] integerValue]];
            tripInfo.pickupLat = [NSNumber numberWithInteger:[response[@"lat"] integerValue]];
            tripInfo.pickupLon = [NSNumber numberWithInteger:[response[@"lon"] integerValue]];

            // Two way relationship
            [tripInfo.passenger addTripsObject:tripInfo];
    
            [KSDBManager saveContext];
        } else {
            [tripInfo MR_deleteEntity];
        }
        completionBlock(status, nil);
    }];

}

+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{}];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:@"/bookings/list" params:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];
        if (KSAPIStatusSuccess == status) {

            for (KSTrip *trip in user.trips.allObjects) {
                trip.passenger = nil;
            }
            [user removeTrips:user.trips];

            NSArray *trips = response[@"data"];
            for (NSDictionary *tripData in trips) {
                KSTrip *trip = [KSTrip objWithValue:tripData[@"job_id"] forAttrib:@"jobId"];
                trip.pickupLandmark = tripData[@"landmark"];
                trip.pickupLat = [NSNumber numberWithDouble:[tripData[@"lat"] doubleValue]];
                trip.pickupLon = [NSNumber numberWithDouble:[tripData[@"lon"] doubleValue]];
                trip.pickupTime = [NSDate dateWithTimeIntervalSince1970:[tripData[@"pick_time"] doubleValue]];
                trip.dropOffLat = [NSNumber numberWithDouble:[tripData[@"drop_lat"] doubleValue]];
                trip.dropOffLon = [NSNumber numberWithDouble:[tripData[@"drop_lon"] doubleValue]];
                trip.dropOffTime = [NSDate dateWithTimeIntervalSince1970:[tripData[@"drop_time"] doubleValue]];
                trip.dropoffLandmark = tripData[@"drop_landmark"];
                trip.status = [NSNumber numberWithInteger:[tripData[@"status"] integerValue]];
#warning TODO: Add remaining data in trip
                trip.passenger = user;
                [user addTripsObject:trip];
            }
            [KSDBManager saveContext];
        }
        completionBlock(status, [user.bookmarks allObjects]);
    }];
}

#pragma mark -
#pragma mark - Trip rating

+ (KSTripRating *)tripRatingForTrip:(KSTrip *)trip {

    KSTripRating *tripRating = trip.rating;
    if (!tripRating) {
        tripRating = [KSTripRating MR_createEntity];
        tripRating.trip = trip;
    }
    return tripRating;
}

+ (void)rateTrip:(KSTrip *)aTrip withRating:(KSTripRating *)aRating completion:(KSDALCompletionBlock)completionBlock {

    __block KSTrip *trip = aTrip;
    __block KSTripRating *rating = aRating;

    if (!rating.comments) {
        rating.comments = @"";
    }
    if (!rating.driverRating) {
        rating.driverRating = @0;
    }
    if (!rating.serviceRating) {
        rating.serviceRating = @0;
    }
    NSDictionary *ratingData = @{
                                 @"job_id": trip.jobId,
                                 @"service": rating.serviceRating,
                                 @"driver": rating.driverRating,
                                 @"comment": rating.comments
                                 };
    NSDictionary *requestData = [self authenticateRequestData:ratingData];
    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:@"/bookings/rating" data:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            trip.rating = rating;
            [KSDBManager saveContext];
        }
        else {
            rating.trip = nil;
        }
        completionBlock(status, nil);
    }];
}

#pragma mark -
#pragma mark - Favorites

+ (void)syncBookmarksWithCompletion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:@{}];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:@"/bookmarks/list" params:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];
        if (KSAPIStatusSuccess == status) {

            for (KSBookmark *bookmark in user.bookmarks.allObjects) {
                bookmark.user = nil;
            }
            [user removeBookmarks:user.bookmarks];

            NSArray *favorites = response[@"data"];

            for (NSDictionary *favorite in favorites) {
                KSBookmark *bookmark = [KSBookmark objWithValue:favorite[@"name"] forAttrib:@"name"];
                bookmark.latitude = [NSNumber numberWithDouble:[favorite[@"lat"] doubleValue]];
                bookmark.longitude = [NSNumber numberWithDouble:[favorite[@"lon"] doubleValue]];

                bookmark.user = user;
                [user addBookmarksObject:bookmark];
            }
            [KSDBManager saveContext];
        }
        completionBlock(status, [user.bookmarks allObjects]);
    }];
}

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *bookmarkData = @{
        @"name": name,
        @"lat": @(coordinate.latitude),
        @"lon": @(coordinate.longitude)
    };
    NSDictionary *requestData = [self authenticateRequestData:bookmarkData];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/bookmarks/add" data:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            KSUser *user = [KSDAL loggedInUser];
            KSBookmark *bookmark = [KSBookmark objWithValue:name forAttrib:@"name"];
            bookmark.latitude = @(coordinate.latitude);
            bookmark.longitude = @(coordinate.longitude);

            bookmark.user = user;
            [user addBookmarksObject:bookmark];
            
            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

+ (void)updateBookmark:(KSBookmark *)aBookmark withName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *bookmarkData = @{
                                   @"old_name": aBookmark.name,
                                   @"name": name,
                                   @"lat": @(coordinate.latitude),
                                   @"lon": @(coordinate.longitude)
                                   };
    __block KSBookmark *bookmark = aBookmark;
    NSDictionary *requestData = [self authenticateRequestData:bookmarkData];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"/bookmarks/update" data:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            bookmark.name = name;
            bookmark.latitude = @(coordinate.latitude);
            bookmark.longitude = @(coordinate.longitude);
            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

+ (void)deleteBookmark:(KSBookmark *)aBookmark completion:(KSDALCompletionBlock)completionBlock {

    __block KSBookmark *bookmark = aBookmark;
    NSDictionary *requestData = [self authenticateRequestData:@{@"name": bookmark.name}];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient POST:@"bookmarks/delete" data:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            KSUser *user = [KSDAL loggedInUser];
            [user removeBookmarksObject:bookmark];
            [bookmark MR_deleteEntity];
            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

#pragma mark -
#pragma mark - Geocoding

+ (void)geocodeWithParams:(NSDictionary *)params completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *requestData = [self authenticateRequestData:params];
    KSWebClient *webClient = [KSWebClient instance];
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
