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
#import "KSGeoLocation.h"

#import "KSSessionInfo.h"
#import "MagicalRecord.h"

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

+ (KSUser *)loggedInUser {
    KSUser *user = nil;
    KSSessionInfo* sessionInfo = [KSSessionInfo currentSession];
    // No need to fetch user if the session ID is not stored
    if (sessionInfo.sessionId) {
        user = [KSUser MR_findFirstByAttribute:@"phone" withValue:sessionInfo.phone];
    }
    return user;
}

+(NSArray*) allUser
{
    return [KSUser MR_findAll];
}
@end
