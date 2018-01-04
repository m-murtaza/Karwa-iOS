//
//  KSTrip.h
//  Kuber
//
//  Created by Asif Kamboh on 10/6/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSBookmark, KSDriver, KSTaxi, KSTripRating, KSUser;

@interface KSTrip : NSManagedObject

@property (nonatomic, retain) NSString * bookingType;
@property (nonatomic, retain) NSString * dropoffLandmark;
@property (nonatomic, retain) NSNumber * dropOffLat;
@property (nonatomic, retain) NSNumber * dropOffLon;
@property (nonatomic, retain) NSDate * dropOffTime;
@property (nonatomic, retain) NSNumber * estimatedTimeOfArival;
@property (nonatomic, retain) NSString * jobId;
@property (nonatomic, retain) NSString * pickupLandmark;
@property (nonatomic, retain) NSNumber * pickupLat;
@property (nonatomic, retain) NSNumber * pickupLon;
@property (nonatomic, retain) NSDate * pickupTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * pickupHint;
@property (nonatomic, retain) NSNumber * vehicleType;
@property (nonatomic, retain) NSString * callerId;

@property (nonatomic, retain) KSDriver *driver;
@property (nonatomic, retain) KSUser *passenger;
@property (nonatomic, retain) KSTripRating *rating;
@property (nonatomic, retain) KSTaxi *taxi;
@property (nonatomic, retain) KSBookmark *tripToBookmark;

@end
