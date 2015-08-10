//
//  KSDAL.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+Location.h"

#import "KSDBManager.h"
#import "KSWebClient.h"

#import "KSUser.h"
#import "KSTrip.h"
#import "KSTripRating.h"
#import "KSBookmark.h"
#import "KSGeoLocation.h"

#import "KSSessionInfo.h"
#import "CoreData+MagicalRecord.h"

@implementation KSDAL (KSLocation)

#pragma mark -
#pragma mark - Geocoding

+ (void)geocodeWithParams:(NSDictionary *)params completion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];

    [webClient GET:@"/geocode" params:@{} completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            completionBlock(status, response);
        }
        else {
            completionBlock(status, nil);
        }
    }];
}

+ (void)syncLocationsWithCompletion:(KSDALCompletionBlock)completionBlock {
    
    static BOOL isRunning = NO;
    static NSMutableArray *blocks = nil;

    if (!blocks) {
        blocks = [NSMutableArray array];
    }

    if (isRunning) {
        [blocks addObject:completionBlock];
        return;
    }
    // Add to existing blocks
    [blocks addObject:completionBlock];
    
    NSTimeInterval syncTimeInterval = [KSSessionInfo locationsSyncTime];
    NSString *uri = [NSString stringWithFormat:@"/geocodes/%ld", (long)(syncTimeInterval * 1000)];
    KSWebClient *webClient = [KSWebClient instance];
    isRunning = YES;
    [webClient GET:uri params:nil completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            [KSSessionInfo updateLocationsSyncTime];

            // Update locations database
            NSArray *locations = response[@"data"];
            [KSDBManager saveLocationsData:locations];
        }

        isRunning = NO;

        for (KSDALCompletionBlock block in blocks) {
            block(status, nil);
        }

        [blocks removeAllObjects];

    }];

}

+ (NSArray *)locationsMatchingText:(NSString *)text {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address contains[c] %@", text];
#warning TODO: Test this method
    NSArray *locations = [KSGeoLocation MR_findAllWithPredicate:predicate];

    return locations;
}

+ (NSArray *)nearestLocationsMatchingLatitude:(double)lat longitude:(double)lon {

    // Threshold radius
    const double latThreshold = 250.0;
    // Search radius is bigger due to high error in longitudes
    const double searchRadius = 250.0; // 1350m radius
    // Square of threshold radius, for comparing with square distance
    const double radiusSquare = searchRadius * searchRadius;
    // Approximate
    const double metersPerDegreeLat = 111000.0;

    double metersPerDegreeLon = metersPerDegreeLat * cos(lat * M_PI / 180.0);
    // To avoid sqrt function call, we keep the square distance
    double (^distanceSquare)(KSGeoLocation *) = ^(KSGeoLocation *location) {
        double metersPerDegreeLon2 = metersPerDegreeLat * cos(location.latitude.doubleValue * M_PI / 180.0);
        double deltaLon = (metersPerDegreeLon * lon - metersPerDegreeLon2 * location.longitude.doubleValue);
        double deltaLat = metersPerDegreeLat * (lat - location.latitude.doubleValue);
        return (deltaLat * deltaLat + deltaLon * deltaLon);
    };

    NSPredicate *latPredicate = [NSPredicate predicateWithBlock:^BOOL(KSGeoLocation *location, NSDictionary *bindings) {
        double deltaLat = (metersPerDegreeLat * (lat - location.latitude.doubleValue));
        deltaLat = deltaLat < 0.0 ? -deltaLat : deltaLat;
        return deltaLat <= latThreshold;
    }];

    NSPredicate *lonPredicate = [NSPredicate predicateWithBlock:^BOOL(KSGeoLocation *location, NSDictionary *bindings) {
        return distanceSquare(location) <= radiusSquare;
    }];
#warning TODO: Fixed issues with this method
    NSArray *locations = [KSGeoLocation MR_findAll];
    locations = [locations filteredArrayUsingPredicate:latPredicate];
    locations = [locations filteredArrayUsingPredicate:lonPredicate];
    if (locations.count > 10) {
        locations = [locations subarrayWithRange:NSMakeRange(0, 10)];
    }
    locations = [locations sortedArrayUsingComparator:^NSComparisonResult(KSGeoLocation *loc1, KSGeoLocation *loc2) {
        return distanceSquare(loc2) - distanceSquare(loc1);
    }];

    return locations;
}

+ (KSGeoLocation *)nearestLocationMatchingLatitude:(double)lat longitude:(double)lon {
    
    return [[self nearestLocationsMatchingLatitude:lat longitude:lon] firstObject];
}

+ (KSGeoLocation *)addGeolocationWithCoordinate:(CLLocationCoordinate2D)coordinate area:(NSString *)area address:(NSString *)address {
    
    KSGeoLocation *location = [KSGeoLocation MR_createEntity];
    location.latitude = @(coordinate.latitude);
    location.longitude = @(coordinate.longitude);
    location.address = address;
    location.area = area;
    location.locationId = @(INT_MAX);
    
    [KSDBManager saveContext];

    return location;
}

@end
