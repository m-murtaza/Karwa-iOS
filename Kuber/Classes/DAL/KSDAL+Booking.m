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
#import "MagicalRecord.h"

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
    [requestData setObjectOrNothing:[NSDate date] forKey:@"CreationTime"];

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
            tripInfo.bookingType = [bookingData[@"BookingType"] lowercaseString];
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

+ (void)cancelTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock {
    
    KSWebClient *webClient = [KSWebClient instance];
    
    NSString *uri = [NSString stringWithFormat:@"/booking/%@", trip.jobId];
    
    [webClient DELETE:uri completion:^(BOOL success, id response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            [trip MR_deleteEntity];
        }
        
        completionBlock(status, nil);
        
        
        //Usman: Temp Fix
        /*[trip MR_deleteEntity];
        completionBlock(1,nil);*/
    }];
}


+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];

    [webClient GET:@"/booking" params:@{} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];
        if (KSAPIStatusSuccess == status) {

//            for (KSTrip *trip in user.trips.allObjects) {
//                trip.passenger = nil;
//            }
//            [user removeTrips:user.trips];

            NSArray *trips = response[@"data"];
            for (NSDictionary *tripData in trips) {
                KSTrip *trip = [KSTrip objWithValue:tripData[@"BookingID"] forAttrib:@"jobId"];
                trip.pickupLat = [NSNumber numberWithDouble:[tripData[@"PickLat"] doubleValue]];
                trip.pickupLon = [NSNumber numberWithDouble:[tripData[@"PickLon"] doubleValue]];
                trip.pickupTime = [tripData[@"PickTime"] dateValue];
                trip.dropOffTime = [tripData[@"DropTime"] dateValue];
                if (tripData[@"PickLocation"])
                    trip.pickupLandmark = tripData[@"PickLocation"];
                if (tripData[@"DropLat"])
                     trip.dropOffLat = [NSNumber numberWithDouble:[tripData[@"DropLat"] doubleValue]];
                if (tripData[@"DropLon"])
                    trip.dropOffLon = [NSNumber numberWithDouble:[tripData[@"DropLon"] doubleValue]];
                if (tripData[@"DropLocation"])
                    trip.dropoffLandmark = tripData[@"DropLocation"];

                trip.status = [NSNumber numberWithInteger:[tripData[@"Status"] integerValue]];
                trip.bookingType = [tripData[@"BookingType"] lowercaseString];

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

+ (NSArray *)recentTripsWithLandmarkText {
    
    NSMutableArray *recentBookings = [NSMutableArray array];
    for (KSTrip *trip in [[[self loggedInUser] trips] allObjects]) {
        
        if (trip.pickupLandmark.length || trip.dropoffLandmark.length) {
            
            [recentBookings addObject:trip];
        }
    }
    return [NSArray arrayWithArray:recentBookings];
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

@end
