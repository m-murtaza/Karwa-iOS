//
//  KSDBManager.m
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//
//  Depedency on MagicalRecord
//

#import "KSDBManager.h"

#import "KSUser.h"
#import "KSTrip.h"
#import "KSGeoLocation.h"

#import "CoreData+MagicalRecord.h"


@implementation KSDBManager

+ (instancetype)instance {
    static KSDBManager *_instance = nil;
    static dispatch_once_t dispatchQueueToken;

    dispatch_once(&dispatchQueueToken, ^{
        _instance = [[KSDBManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // TODO: Add custom init code
    }
    return self;
}

+ (void)saveContext {

    [[self instance] saveContext];
}

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon {
    KSTrip *trip = [KSTrip MR_createEntity];
    trip.pickupLandmark = landmark;
    trip.pickupLat = [NSNumber numberWithDouble:lat];
    trip.pickupLon = [NSNumber numberWithDouble:lon];

    return trip;
}

+ (void)saveLocationsData:(NSArray *)locations
{
    [[self instance] performSelectorInBackground:@selector(saveLocationsData:) withObject:locations];
}

- (void)saveLocationsData:(NSArray *)locations {

    for (NSDictionary *loc in locations) {
        NSNumber *locationId = loc[@"id"];
        KSGeoLocation *geolocation = [KSGeoLocation objWithValue:locationId forAttrib:@"locationId"];
        geolocation.latitude = loc[@"lat"];
        geolocation.longitude = loc[@"lon"];
        geolocation.area = loc[@"area"];
        geolocation.address = loc[@"address"];
    }

    [self saveContext];
    
}

- (void)saveContext {
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

@end
