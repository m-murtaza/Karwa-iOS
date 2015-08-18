//
//  KSDAL+Location.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSDAL.h"

@class KSGeoLocation;

@interface KSDAL (KSLocation)

+ (void)geocodeWithParams:(NSDictionary *)params completion:(KSDALCompletionBlock)completionBlock;

+ (void)syncLocationsWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (NSArray *)locationsMatchingText:(NSString *)text;

+ (NSArray *)nearestLocationsMatchingLatitude:(double)lat longitude:(double)lon;

+ (KSGeoLocation *)nearestLocationMatchingLatitude:(double)lat longitude:(double)lon;

+ (NSArray *)nearestLocationsMatchingLatitude:(double)lat
                                    longitude:(double)lon
                                       radius:(double)searchRadius;

+ (KSGeoLocation *)addGeolocationWithCoordinate:(CLLocationCoordinate2D)coordinate area:(NSString *)area address:(NSString *)address;

+ (void)taxisNearCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius completion:(KSDALCompletionBlock)completionBlock;

@end
