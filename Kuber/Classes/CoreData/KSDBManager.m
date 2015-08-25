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
#import "KSTripIssue.h"


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

+ (void)saveContext:(void(^)())completionBlock {

    [[self instance] saveContext: completionBlock];
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

    [self saveContext:NULL];
}

+ (void) saveIssuesData:(NSArray*) issues
{
    
    for (NSDictionary *issue in issues) {
        
        NSString *issueKey = issue[@"IssueKey"];
        KSTripIssue *tripIssue = [KSTripIssue objWithValue:issueKey forAttrib:@"issueKey"];
        tripIssue.issueKey = issue[@"IssueKey"];
        tripIssue.valueEN = issue[@"IssueEN"];
        tripIssue.valueAR = issue[@"IssueAR"];
    }
    
    [self saveContext:NULL];
}

- (void)saveContext:(void(^)())completionBlock {
    
    NSManagedObjectContext *currentCtx = [NSManagedObjectContext MR_contextForCurrentThread];
    NSManagedObjectContext *defaultCtx = [NSManagedObjectContext MR_defaultContext];
    if (currentCtx != defaultCtx) {
        [currentCtx MR_saveToPersistentStoreAndWait];
    }
    else {
        [defaultCtx MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Error saving context: %@", error.description);
            }
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
}

@end
