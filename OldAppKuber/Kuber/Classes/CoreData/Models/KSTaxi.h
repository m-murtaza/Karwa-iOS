//
//  KSTaxi.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSTrip;

@interface KSTaxi : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSSet *trips;
@end

@interface KSTaxi (CoreDataGeneratedAccessors)

- (void)addTripsObject:(KSTrip *)value;
- (void)removeTripsObject:(KSTrip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
