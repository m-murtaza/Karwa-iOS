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
#import "MagicalRecord.h"
#import "KSLocation.h"

#define BOOKING_SYNC_TIME @"bookingSyncTime"
#define BOOKING_LIST_NUM_RECORD 20


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
    [requestData setObjectOrNothing:[trip.pickupTime bookingDateServerFormat] forKey:@"PickTime"];
    [requestData setObjectOrNothing:trip.dropOffLat forKey:@"DropLat"];
    [requestData setObjectOrNothing:trip.dropOffLon forKey:@"DropLon"];
    [requestData setObjectOrNothing:trip.dropoffLandmark forKey:@"DropLocation"];
    [requestData setObjectOrNothing:[[NSDate date] bookingDateServerFormat] forKey:@"CreationTime"];
    [requestData setObjectOrNothing:trip.pickupHint forKey:@"PickMessage"];

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
    }];
}


//TODO: Need to optimize repitative code.
+ (void) syncUnRatedBookingsWithCompletion:(KSDALCompletionBlock)completionBlock
{
    KSWebClient *webClient = [KSWebClient instance];
    
    [webClient GET:@"/booking" params:@{@"type":@"unrated"} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if(KSAPIStatusSuccess == status){
            
            NSArray *trips = response[@"data"];
            NSArray *ksTrips = [KSDAL addTrips:trips];
            [KSDBManager saveContext:^{
                
                completionBlock(status, ksTrips);
            }];
        }
        else{
            
            completionBlock(status, nil);
        }
    }];
}

+ (void) syncPendingBookingsWithCompletion:(KSDALCompletionBlock)completionBlock;
{
    KSWebClient *webClient = [KSWebClient instance];
    
    [webClient GET:@"/booking" params:@{@"type":@"pending"} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if(KSAPIStatusSuccess == status){
            
            NSArray *trips = response[@"data"];
            //DLog(@"%@",trips);
            NSArray *ksTrips = [KSDAL addTrips:trips];
            [KSDBManager saveContext:^{
    
                completionBlock(status, ksTrips);
            }];
        }
        else{
        
           completionBlock(status, nil);
        }
    }];
}

+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];

    [webClient GET:@"/booking" params:@{@"synctime":[KSDAL bookingSyncTime]} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];
        if (KSAPIStatusSuccess == status) {
            
            NSArray *trips = response[@"data"];
            //DLog(@"%@",trips);
            [KSDAL addTrips:trips];
           
            [KSDBManager saveContext:^{
                [KSDAL updateBookingSyncTime];
                completionBlock(status, [user.trips allObjects]);
            }];
        }
        else {
            completionBlock(status, [user.trips allObjects]);
        }
    }];
}

+ (NSArray *)recentTripDestinationGeoLocation:(NSInteger)numRecord;
{
    NSMutableArray *recentBookings = [NSMutableArray array];
    NSArray * arr = [[[self loggedInUser] trips] allObjects];
    NSSortDescriptor *sdesc = [[NSSortDescriptor alloc] initWithKey:@"pickupTime" ascending:NO];
    
    NSArray *sortedArry = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdesc]];
    
    int i = 0;
    
    for (KSTrip *trip in sortedArry) {
        
        if (trip.dropoffLandmark.length) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude == %@ && longitude == %@",trip.dropOffLat,trip.dropOffLon];
            
            NSArray *tempArray = [recentBookings filteredArrayUsingPredicate:predicate];
            if (tempArray == nil || tempArray.count == 0) {
                //Find geolocation for dropoff land mark
                KSGeoLocation * geolocation = [KSDAL geolocationWithLandmark:trip.dropOffLat Longitude:trip.dropOffLon];
                if (geolocation) {
                   
                    [recentBookings addObject:geolocation];
                    i++;
                    if (i >= numRecord)
                        break;
                }
            }
        }
    }
    return [NSArray arrayWithArray:recentBookings];
}

    


+ (NSArray *)recentTripsWithLandmark:(NSInteger)numRecord
{
    NSMutableArray *recentBookings = [NSMutableArray array];
    NSArray * arr = [[[self loggedInUser] trips] allObjects];
    NSSortDescriptor *sdesc = [[NSSortDescriptor alloc] initWithKey:@"pickupTime" ascending:NO];
    
    NSArray *sortedArry = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdesc]];
    
    int i = 0;
    
    
    for (KSTrip *trip in sortedArry) {
    
        if (trip.pickupLandmark.length) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pickupLandmark = %@",trip.pickupLandmark];
            
            NSArray *tempArray = [recentBookings filteredArrayUsingPredicate:predicate];
            if (tempArray == nil || tempArray.count == 0) {
                [recentBookings addObject:trip];
                i++;
                if (i >= numRecord) {
                    break;
                }
            }
            
            
        }
        
    }
    return [NSArray arrayWithArray:recentBookings];
}

/*+ (NSArray *)recentTripsWithLandmark:(NSInteger)numRecord
{
    NSMutableArray *recentBookings = [NSMutableArray array];
    NSArray * arr = [[[self loggedInUser] trips] allObjects];
    NSSortDescriptor *sdesc = [[NSSortDescriptor alloc] initWithKey:@"pickupTime" ascending:NO];
    
    NSArray *sortedArry = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdesc]];
    
    int i = 0;
    
    
    for (KSTrip *trip in sortedArry) {
        for (KSLocation *l in recentBookings) {
            NSLog(@"%@ - %f - %f",l.landmark,l.location.latitude,l.location.longitude);
        }
        if (trip.pickupLandmark.length && [trip.pickupLat doubleValue] != 0.0 && [trip.pickupLon doubleValue] != 0.0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"landmark = %@",trip.pickupLandmark];
            
            NSArray *tempArray = [recentBookings filteredArrayUsingPredicate:predicate];
            if (tempArray == nil || tempArray.count == 0) {
                
                 CLLocationCoordinate2D pLocation = CLLocationCoordinate2DMake([trip.pickupLat doubleValue], [trip.pickupLon doubleValue]);
                KSLocation *location = [[KSLocation alloc] initWithLandmark:trip.pickupLandmark location:pLocation Hint:trip.pickupHint];
                
                [recentBookings addObject:location];
                i++;
                if (i >= numRecord) {
                    break;
                }
            }
        }
        if (trip.dropoffLandmark.length && ![trip.dropoffLandmark isEqualToString:@"---"] && [trip.dropOffLat doubleValue] != 0 && [trip.dropOffLon doubleValue] != 0.0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"landmark = %@",trip.dropoffLandmark];
            
            NSArray *tempArray = [recentBookings filteredArrayUsingPredicate:predicate];
            if (tempArray == nil || tempArray.count == 0) {
                
                CLLocationCoordinate2D pLocation = CLLocationCoordinate2DMake([trip.dropOffLat doubleValue], [trip.dropOffLon doubleValue]);
                KSLocation *location = [[KSLocation alloc] initWithLandmark:trip.dropoffLandmark location:pLocation Hint:@""];
                
                [recentBookings addObject:location];
                i++;
                if (i >= numRecord) {
                    break;
                }
            }
        }
        
    }
    return [NSArray arrayWithArray:recentBookings];
}*/


+ (NSArray *)recentTripsWithLandmarkText {
    
    NSMutableArray *recentBookings = [NSMutableArray array];
    for (KSTrip *trip in [[[self loggedInUser] trips] allObjects]) {
        
        if (trip.pickupLandmark.length || trip.dropoffLandmark.length) {
            
            [recentBookings addObject:trip];
        }
    }
    return [NSArray arrayWithArray:recentBookings];
}

+(void) bookingWithBookingId:(NSString*)bookingId completion:(KSDALCompletionBlock)completionBlock
{
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:[NSString stringWithFormat:@"/booking/%@",bookingId]
            params:nil
        completion:^(BOOL success, id response) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            if(KSAPIStatusSuccess == status){
                
                NSDictionary * tripData = response[@"data"];
                KSTrip *trip = [self addTrip:tripData];
            
                [KSDBManager saveContext:^{
                    completionBlock(status, trip);
                }];
            }
            else{
                NSLog(@"Failed booking Detail");
            }
        }];
}

+ (NSArray*) fetchPendingBookingHistoryFromDB
{
    NSPredicate *pendingPredicate = [NSPredicate predicateWithFormat:@"status == %d || status == %d || status == %d || status == %d || status == %d",KSTripStatusOpen,KSTripStatusInProcess,KSTripStatusPending,KSTripStatusManuallyAssigned,KSTripStatusTaxiAssigned];
    NSArray *pendingBookings = [KSTrip MR_findAllSortedBy:@"pickupTime"
                                                ascending:YES
                                            withPredicate:pendingPredicate ];
    return pendingBookings;
    
}
+ (NSArray*) fetchTopNonPendingBookingHistoryFromDB
{
    return [KSDAL fetchTopNonPendingBookingHistoryFromDB:0 Limit:BOOKING_LIST_NUM_RECORD];
}

+ (NSArray*) fetchTopNonPendingBookingHistoryFromDB:(NSInteger)offset Limit:(NSInteger)limit
{
    NSPredicate *otherBookingsPredicate = [NSPredicate predicateWithFormat:@"status != %d && status != %d && status != %d && status != %d && status != %d",KSTripStatusOpen,KSTripStatusInProcess,KSTripStatusPending,KSTripStatusManuallyAssigned,KSTripStatusTaxiAssigned];
    
    
    NSFetchRequest *otherBookingFetchRequest = [KSTrip MR_requestAllWithPredicate:otherBookingsPredicate];
    
    [otherBookingFetchRequest setFetchOffset:offset];
    if (limit>0) {
            [otherBookingFetchRequest setFetchLimit:limit];
    }
    
    
    NSSortDescriptor *otherBookingSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:otherBookingSortDescriptor];
    [otherBookingFetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *otherBookings = [KSTrip MR_executeFetchRequest:otherBookingFetchRequest];
    return otherBookings;
}

+ (NSArray*) fetchBookingHistoryFromDB
{
    
    NSArray *pendingBookings = [KSDAL fetchPendingBookingHistoryFromDB];
    NSArray *otherBookings = [KSDAL fetchTopNonPendingBookingHistoryFromDB];
    
    NSArray * bookingHistory = [pendingBookings arrayByAddingObjectsFromArray:otherBookings];
    return bookingHistory;
    
}

+ (void) removeOldBookings
{
    NSArray *otherBookings = [KSDAL fetchTopNonPendingBookingHistoryFromDB:50 Limit:0];
    for (KSTrip *trip in otherBookings) {
      
        [trip MR_deleteEntity];
    }
    [KSDBManager saveContext:nil];
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

#pragma mark - Private functions

+(NSArray*) addTrips:(NSArray*) trips
{
    NSMutableArray *tripsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *tripData in trips) {
         [tripsArray addObject:[KSDAL addTrip:tripData]];
    }
    return [NSArray arrayWithArray:tripsArray];
}

+(KSTrip*) addTrip:(NSDictionary*) tripData
{
    KSUser *user = [KSDAL loggedInUser];
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
    
    if (tripData[@"ETA"] && [tripData[@"ETA"] integerValue] > 0) {
        
        trip.estimatedTimeOfArival = tripData[@"ETA"];
    }
    
    if(tripData[@"PickMessage"]){
        trip.pickupHint = tripData[@"PickMessage"];
    }
    
    //Driver Information
    if ([tripData[@"DriverID"] integerValue] > 0){
        
        KSDriver *driver = [KSDriver objWithValue:[tripData[@"DriverID"] stringValue] forAttrib:@"driverId"];
        driver.name = tripData[@"DriverName"];
        driver.phone = tripData[@"DriverPhone"];
        [driver addTripsObject:trip];
        trip.driver = driver;
    }
    
    //Taxi info
    if (tripData[@"TaxiNo"]) {
        
        KSTaxi *taxi = [KSTaxi objWithValue:tripData[@"TaxiNo"] forAttrib:@"number"];
        taxi.number = tripData[@"TaxiNo"];
        [taxi addTripsObject:trip];
        trip.taxi = taxi;
    }
    
    trip.passenger = user;
    
    if (tripData[@"Rating"]) {
        NSDictionary *rateData = tripData[@"Rating"];
        KSTripRating *tripRating = [KSTripRating MR_createEntity];
        tripRating.serviceRating = rateData[@"Value"];
        tripRating.issue = rateData[@"Options"] ? rateData[@"Options"] : @"";
        tripRating.comments = rateData[@"Remarks"] ? rateData[@"Remarks"] : @"";
        tripRating.trip = trip;
        trip.rating = tripRating;
    
    }
    
    [user addTripsObject:trip];
    return trip;
}

+(NSString*) bookingSyncTime
{
    NSDate *syncDate = [[NSUserDefaults standardUserDefaults] objectForKey:BOOKING_SYNC_TIME];
    if (!syncDate) {

        syncDate = [self defaultSyncDate];
    }
    
    NSTimeInterval syncTimeInterval = [syncDate timeIntervalSince1970];
    NSString *strSyncTimeInterval = [NSString stringWithFormat:@"%f",syncTimeInterval];
    return strSyncTimeInterval;
    
}

+(void) updateBookingSyncTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:BOOKING_SYNC_TIME];
    [defaults synchronize];
}

+(void) removeSyncTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:BOOKING_SYNC_TIME];
    [defaults synchronize];
}

+(NSDate*) defaultSyncDate
{
    return [NSDate dateWithTimeIntervalSince1970:0];        //Default date of 1970
}


@end
