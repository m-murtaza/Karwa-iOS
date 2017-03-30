//
//  KSDAL+Booking.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSTrip;
@class KSTripRating;

@interface KSDAL (KSBooking)

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon;

+ (void)bookTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock;

+ (void)cancelTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock;

+ (NSArray*) TaxiTrips:(NSArray*) trips;
+ (NSArray*) LimoTrips:(NSArray*) trips ; 

+ (KSTripRating *)tripRatingForTrip:(KSTrip *)trip;

+ (void)rateTrip:(KSTrip *)aTrip withRating:(KSTripRating *)aRating completion:(KSDALCompletionBlock)completionBlock;

+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (void) syncPendingBookingsWithCompletion:(KSDALCompletionBlock)completionBlock;
+ (void) syncUnRatedBookingsWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (NSArray *)recentTripsWithLandmark:(NSInteger)numRecord;
+ (NSArray *)recentTripDestinationGeoLocation:(NSInteger)numRecord;

+ (NSArray *)recentTripsWithLandmarkText;

+(void) bookingWithBookingId:(NSString*)bookingId completion:(KSDALCompletionBlock)completionBlock;

+ (NSArray*) fetchTaxiBookingDB;
+ (NSArray*) fetchLimoBookingDB;
//+ (NSArray*) pendingBookingsDB;
+ (NSArray*) topFinishedBookingsDB;

+ (void) removeOldBookings;
+ (void) removeAllBookings;

+(void) removeSyncTime;

//+(NSString*) bookingSyncTime;
//+(void) updateBookingSyncTime;
//+(NSDate*) defaultSyncDate;
@end
