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
    
    NSTimeInterval syncTimeInterval = [KSSessionInfo locationsSyncTime];
    NSString *uri = [NSString stringWithFormat:@"/geocodes/%ld", (long)(syncTimeInterval * 1000)];
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:uri params:nil completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            [KSSessionInfo updateLocationsSyncTime];

            // Update locations database
            NSArray *locations = response[@"data"];
            [KSDBManager saveLocationsData:locations];

        }
        completionBlock(status, nil);
        
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
    const double radius = 250.; // 250m radius
    // Square of threshold radius, for comparing with square distance
    const double radiusSquare = radius * radius;
    const double metersPerDegreeLat = 111500.;

    double (^toRadians)(double) = ^(double degrees) {

        return degrees * M_PI / 180.;
    };

    double metersPerDegreeLon = metersPerDegreeLat * cos(toRadians(lat));
    // To avoid sqrt function call, we keep the square distance
    double (^distanceSquare)(KSGeoLocation *) = ^(KSGeoLocation *location) {
        double metersPerDegreeLon2 = metersPerDegreeLat * cos(toRadians(location.latitude.doubleValue));
        double deltaLon = fabs(metersPerDegreeLon * lon - metersPerDegreeLon2 * location.longitude.doubleValue);
        double deltaLat = fabs(metersPerDegreeLat * (lat - location.latitude.doubleValue));
        return (deltaLat * deltaLat + deltaLon * deltaLon);
    };

    NSPredicate *latPredicate = [NSPredicate predicateWithBlock:^BOOL(KSGeoLocation *location, NSDictionary *bindings) {
        double deltaLat = fabs(metersPerDegreeLat * (lat - location.latitude.doubleValue));
        return deltaLat <= radius;
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

@end
