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
#import <MagicalRecord/MagicalRecord.h>
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
    [requestData setObjectOrNothing:trip.vehicleType forKey:@"VehicleType"];
    [requestData setObjectOrNothing:trip.callerId forKey:@"CallerID"];
    
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
            //[trip MR_deleteEntity];
        }
        
        completionBlock(status, nil);
    }];
}

+ (NSArray*) TaxiTrips:(NSArray*) trips {
    
    NSArray *fTrips = [trips filteredArrayUsingPredicate:[KSDAL taxiPredicate]];
    return fTrips;
}

+(NSArray*) LimoTrips:(NSArray*) trips {
    
    return [trips filteredArrayUsingPredicate:[KSDAL limoPredicate]];
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
            completionBlock(status, ksTrips);
        }
        else{
            
            completionBlock(status, nil);
        }
    }];
}

+ (void) syncUnRatedBookingsSinceDate:(NSDate*)date Completion:(KSDALCompletionBlock)completionBlock
{
    NSString *synctime = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    NSDictionary *params =@{@"type":@"unrated" , @"synctime":synctime};
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:@"/booking"
            params:params
        completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if(KSAPIStatusSuccess == status){

            NSArray *trips = response[@"data"];
            NSArray *ksTrips = [KSDAL addTrips:trips];
            completionBlock(status, ksTrips);
        }
        else{

            completionBlock(status, nil);
        }
    }];
}

+ (void) syncUnRatedBookingsForLastThreeDaysWithCompletion:(KSDALCompletionBlock)completionBlock
{
    NSDate *beforeThreeDays = [[NSDate date] dateBySubtractingDays:3];
    [self syncUnRatedBookingsSinceDate:beforeThreeDays
                            Completion:completionBlock];
    
//    KSWebClient *webClient = [KSWebClient instance];
//
//    [webClient GET:@"/booking" params:@{@"type":@"unrated"} completion:^(BOOL success, NSDictionary *response) {
//        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
//        if(KSAPIStatusSuccess == status){
//
//            NSArray *trips = response[@"data"];
//            NSArray *ksTrips = [KSDAL addTrips:trips];
//            [KSDBManager saveContext:^{
//
//                completionBlock(status, ksTrips);
//            }];
//        }
//        else{
//
//            completionBlock(status, nil);
//        }
//    }];
}

+ (void) syncPendingBookingsWithCompletion:(KSDALCompletionBlock)completionBlock;
{
    KSWebClient *webClient = [KSWebClient instance];
    
    [webClient GET:@"/booking" :@{@"type":@"pending"} completion:^(BOOL success, NSDictionary *response) {
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

+ (NSArray*) pendingTaxiBookingsDB
{
    return [KSDAL pendingBookingsDBWithPredicate:[KSDAL taxiPredicate]];
}

+ (NSPredicate*) taxiPredicate
{
    return [NSPredicate predicateWithFormat:@"vehicleType ==  %d || vehicleType == %d || vehicleType == %d || vehicleType == %d || vehicleType == %d",KSCityTaxi,KSAiport7Seater,KSAirportSpare,KSSpecialNeedTaxi,KSAiportTaxi];
}

+(NSPredicate*) limoPredicate
{
    return [NSPredicate predicateWithFormat:@"vehicleType == %d || vehicleType == %d || vehicleType == %d",KSStandardLimo,KSBusinessLimo,KSLuxuryLimo];
}

+ (NSArray*) pendingLimoBookingsDB
{
    return [KSDAL pendingBookingsDBWithPredicate:[KSDAL limoPredicate]];
}

+ (NSArray*) pendingBookingsDBWithPredicate:(NSPredicate*) predicate
{
    NSPredicate *pendingPredicate = [NSPredicate predicateWithFormat:@"status == %d || status == %d || status == %d || status == %d || status == %d || status == %d",KSTripStatusOpen,KSTripStatusInProcess,KSTripStatusPending,KSTripStatusManuallyAssigned,KSTripStatusTaxiAssigned, KSTripStatusPassengerInTaxi];
    
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pendingPredicate,predicate]];
    NSArray *pendingBookings = [KSTrip MR_findAllSortedBy:@"pickupTime"
                                                 ascending:YES
                                             withPredicate:compoundPredicate];
   return pendingBookings;
    
}

+ (NSArray*) topFinishedLimoBookingsDB
{
    return [KSDAL topFinishedBookingsDBWithPredicate:[KSDAL limoPredicate]];
}

+ (NSArray*) topFinishedLimoBookingsDB:(NSInteger)offset Limit:(NSInteger)limit
{
    return [KSDAL topFinishedBookingsDB:offset Limit:limit Predicate:[KSDAL limoPredicate]];
}

+ (NSArray*) topFinishedTaxiBookingsDB
{
    return [KSDAL topFinishedBookingsDBWithPredicate:[KSDAL taxiPredicate]];
}

+ (NSArray*) topFinishedTaxiBookingsDB:(NSInteger)offset Limit:(NSInteger)limit
{
    return [KSDAL topFinishedBookingsDB:offset Limit:limit Predicate:[KSDAL taxiPredicate]];
}

+ (NSArray*) topFinishedBookingsDBWithPredicate:(NSPredicate*) predicate
{
    return [KSDAL topFinishedBookingsDB:0 Limit:BOOKING_LIST_NUM_RECORD Predicate:predicate];
}

+ (NSArray*) topFinishedBookingsDB:(NSInteger)offset Limit:(NSInteger)limit Predicate:(NSPredicate*) predicate
{
    NSPredicate *finishedBookingsPredicate = [NSPredicate predicateWithFormat:@"status != %d && status != %d && status != %d && status != %d && status != %d && status != %d",KSTripStatusOpen,KSTripStatusInProcess,KSTripStatusPending,KSTripStatusManuallyAssigned,KSTripStatusTaxiAssigned, KSTripStatusPassengerInTaxi];
    
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[finishedBookingsPredicate,predicate]];
    
    NSFetchRequest *finishedBookingFetchRequest = [KSTrip MR_requestAllWithPredicate:compoundPredicate];
    
    [finishedBookingFetchRequest setFetchOffset:offset];
    if (limit>0) {
            [finishedBookingFetchRequest setFetchLimit:limit];
    }
    
    
    NSSortDescriptor *otherBookingSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:otherBookingSortDescriptor];
    [finishedBookingFetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *otherBookings = [KSTrip MR_executeFetchRequest:finishedBookingFetchRequest];
    return otherBookings;
}

+ (NSArray*) fetchTaxiBookingDB
{
    NSArray *pendingBookings = [KSDAL pendingTaxiBookingsDB];
    NSArray *otherBookings = [KSDAL topFinishedTaxiBookingsDB];
    
    NSArray * bookingHistory = [pendingBookings arrayByAddingObjectsFromArray:otherBookings];
    return bookingHistory;
}

+(NSArray*) fetchLimoBookingDB
{
    NSArray *pendingBookings = [KSDAL pendingLimoBookingsDB];
    NSArray *otherBookings = [KSDAL topFinishedLimoBookingsDB];
    
    NSArray * bookingHistory = [pendingBookings arrayByAddingObjectsFromArray:otherBookings];
    return bookingHistory;
}

+ (void) removeOldBookings
{
    NSArray *oldTaxiBookings = [KSDAL topFinishedTaxiBookingsDB:50 Limit:0];
    NSArray *oldLimoBookings = [KSDAL topFinishedLimoBookingsDB:50 Limit:0];
    
    NSArray *oldBookings = [oldTaxiBookings arrayByAddingObjectsFromArray:oldLimoBookings];
    
    for (KSTrip *trip in oldBookings) {
      
        [trip MR_deleteEntity];
    }
    
    [KSDBManager saveContext:nil];
}

+ (void) removeAllBookings
{
    [KSUser MR_truncateAll];
    [KSTrip MR_truncateAll];
}
#pragma mark -
#pragma mark - Trip rating

+ (KSTripRating *)tripRatingForTrip:(KSTrip *)trip {

    KSTripRating *tripRating = trip.rating;
    if (!tripRating) {
        tripRating = [KSTripRating MR_createEntity];
        //tripRating.trip = trip;
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

            [trip MR_inThreadContext].rating = [rating MR_inThreadContext];
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
        KSTrip *trip = [KSDAL addTrip:tripData];
        if(trip)
         [tripsArray addObject:trip];
    }
    return [NSArray arrayWithArray:tripsArray];
}

+(KSTrip*) addTrip:(NSDictionary*) tripData
{
    KSUser *user = [KSDAL loggedInUser];
    KSTrip *trip = [KSTrip objWithValue:tripData[@"BookingID"] forAttrib:@"jobId"];
    if(tripData[@"BookingID"] == nil || trip.jobId == nil)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Error-Rating"     // Event category (required)
                                                              action:(tripData[@"BookingID"] == nil) ? @"AddTrip Booking id nil from server" : @"AddTrip Booking id nil when inserted in DB"  // Event action (required)
                                                               label:[NSString stringWithFormat:@"CallerId: %@ || PickupTime: %@",tripData[@"CallerID"],[tripData[@"PickTime"] dateValue]]
                                                               value:nil] build]];    // Event value
        return nil;
    }
    trip.pickupLat = [NSNumber numberWithDouble:[tripData[@"PickLat"] doubleValue]];
    trip.pickupLon = [NSNumber numberWithDouble:[tripData[@"PickLon"] doubleValue]];
    trip.pickupTime = [tripData[@"PickTime"] dateValue];
    trip.dropOffTime = [tripData[@"DropTime"] dateValue];
    
    if(tripData[@"CallerID"])
        trip.callerId = tripData[@"CallerID"];
    
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
    
    if(tripData[@"VehicleType"] && [tripData[@"VehicleType"] integerValue] > 0)
    {
        trip.vehicleType = tripData[@"VehicleType"];
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
