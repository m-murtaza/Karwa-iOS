//
//  KSTrip.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSTripRating;
@class KSUser;
@class KSTaxi;
@class KSDriver;

@interface KSTrip : NSManagedObject

@property (nonatomic, retain) NSString * jobId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * pickupLat;
@property (nonatomic, retain) NSNumber * pickupLon;
@property (nonatomic, retain) NSNumber * dropOffLat;
@property (nonatomic, retain) NSNumber * dropOffLon;
@property (nonatomic, retain) NSDate * pickupTime;
@property (nonatomic, retain) NSDate * dropOffTime;
@property (nonatomic, retain) KSTripRating *rating;
@property (nonatomic, retain) KSTaxi *taxi;
@property (nonatomic, retain) KSDriver *driver;
@property (nonatomic, retain) KSUser *passenger;

@end
