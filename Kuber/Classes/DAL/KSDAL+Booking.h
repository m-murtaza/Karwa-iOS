//
//  KSDAL+Booking.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSDAL.h"

@class KSTrip;
@class KSTripRating;

@interface KSDAL (KSBooking)

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon;

+ (void)bookTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock;

+ (void)cancelTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock;

+ (KSTripRating *)tripRatingForTrip:(KSTrip *)trip;

+ (void)rateTrip:(KSTrip *)aTrip withRating:(KSTripRating *)aRating completion:(KSDALCompletionBlock)completionBlock;

+ (void)syncBookingHistoryWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (NSArray *)recentTripsWithLandmarkText;

+(void) bookingWithBookingId:(NSString*)bookingId completion:(KSDALCompletionBlock)completionBlock;

@end
