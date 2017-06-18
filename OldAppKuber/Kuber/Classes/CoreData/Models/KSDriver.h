//
//  KSDriver.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSTrip;

@interface KSDriver : NSManagedObject

@property (nonatomic, retain) NSString * driverId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSSet *trips;
@end

@interface KSDriver (CoreDataGeneratedAccessors)

- (void)addTripsObject:(KSTrip *)value;
- (void)removeTripsObject:(KSTrip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
