//
//  KSDAL+Booking.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+Booking.h"

#import "KSDBManager.h"
#import "KSWebClient.h"

#import "KSUser.h"
#import "KSTrip.h"
#import "KSTripRating.h"
#import "KSBookmark.h"
#import "KSGeoLocation.h"

#import "KSSessionInfo.h"
#import "CoreData+MagicalRecord.h"

@implementation KSDAL (KSBooking)


#pragma mark -
#pragma mark - Trip management

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon {

    KSTrip *trip = [KSDBManager tripWithLandmark:landmark lat:lat lon:lon];
    trip.passenger = [self loggedInUser];

    return trip;
}

+ (void)bookTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock {

    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];

    [requestData setObjectOrNothing:trip.pickupLandmark forKey:@"PickLocation"];
    [requestData setObjectOrNothing:trip.pickupLat forKey:@"PickLat"];
    [requestData setObjectOrNothing:trip.pickupLon forKey:@"PickLon"];
    [requestData setObjectOrNothing:trip.pickupTime forKey:@"PickTime"];
    [requestData setObjectOrNothing:trip.dropOffLat forKey:@"DropLat"];
    [requestData setObjectOrNothing:trip.dropOffLon forKey:@"DropLon"];
    [requestData setObjectOrNothing:trip.dropoffLandmark forKey:@"DropLocation"];

    KSWebClient *webClient = [KSWebClient instance];
    __block KSTrip *tripInfo = trip;
    [webClient POST:@"/booking" data:requestData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            NSDictionary *bookingData = response[@"data"];
            tripInfo.jobId = bookingData[@"BookingID"];
            tripInfo.status = [NSNumber numberWithInteger:[bookingData[@"Status"] integerValue]];
            tripInfo.pickupLat = [NSNumber numberWithInteger:[bookingData[@"PickLat"] integerValue]];
            tripInfo.pickupLon = [NSNumber numberWithInteger:[bookingData[@"PickLon"] integerValue]];

            // Two way relationship
            [tripInfo.passenger addTripsObject:tripInfo];
    
            [KSDBManager saveContext:^{
                completionBlock(status, nil);
            }];
        }
        else {
            
            [tripInfo MR_deleteEntity];
            completionBlock(status, nil);
        }
    }];

}

+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

    [webClient GET:@"/booking" params:@{} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];
        if (KSAPIStatusSuccess == status) {

            for (KSTrip *trip in user.trips.allObjects) {
                trip.passenger = nil;
            }
            [user removeTrips:user.trips];

            NSArray *trips = response[@"data"];
            for (NSDictionary *tripData in trips) {
                KSTrip *trip = [KSTrip objWithValue:tripData[@"BookingID"] forAttrib:@"jobId"];
                trip.pickupLandmark = tripData[@"PickLocation"];
                trip.pickupLat = [NSNumber numberWithDouble:[tripData[@"PickLat"] doubleValue]];
                trip.pickupLon = [NSNumber numberWithDouble:[tripData[@"PickLon"] doubleValue]];
                trip.pickupTime = [dateFormatter dateFromString:tripData[@"PickTime"]];
                trip.dropOffLat = [NSNumber numberWithDouble:[tripData[@"DropLat"] doubleValue]];
                trip.dropOffLon = [NSNumber numberWithDouble:[tripData[@"DropLon"] doubleValue]];
                trip.dropOffTime = [dateFormatter dateFromString:tripData[@"DropTime"]];
                trip.dropoffLandmark = tripData[@"DropLocation"];
                trip.status = [NSNumber numberWithInteger:[tripData[@"Status"] integerValue]];
#warning TODO: Add remaining data in trip
                trip.passenger = user;
                [user addTripsObject:trip];
            }
            [KSDBManager saveContext:^{
                completionBlock(status, [user.trips allObjects]);
            }];
        }
        else {
            completionBlock(status, [user.trips allObjects]);
        }
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
    if (!rating.issue) {
        rating.issue = @"OTHER";
    }
    if (!rating.serviceRating) {
        rating.serviceRating = @0;
    }

    NSDictionary *ratingData = @{
                                 @"JobNo": trip.jobId,
                                 @"Rating": rating.serviceRating,
                                 @"Options": rating.issue,
                                 @"Remarks": rating.comments
                                 };

    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:@"/rate" data:ratingData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {

            trip.rating = rating;
            [KSDBManager saveContext:^{
                completionBlock(status, nil);
            }];
        }
        else {
            rating.trip = nil;
            completionBlock(status, nil);
        }
    }];
}

+ (NSArray *)recentBookingsWithAddress {
    
    NSMutableArray *recentBookings = [NSMutableArray array];
    for (KSTrip *trip in [[[self loggedInUser] trips] allObjects]) {
        
        if (trip.pickupLandmark.length || trip.dropoffLandmark.length) {
            
            [recentBookings addObject:trip];
        }
    }
    return [NSArray arrayWithArray:recentBookings];
}

@end
