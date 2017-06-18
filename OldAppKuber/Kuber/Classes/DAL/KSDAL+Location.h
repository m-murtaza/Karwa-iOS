//
//  KSDAL+Location.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

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

+ (void)nearestLocationsFromServerMatchingLatitude:(double)lat
                                         longitude:(double)lon
                                            radius:(double)searchRadius
                                        completion:(KSDALCompletionBlock)completionBlock;

+ (KSGeoLocation *)addGeolocationWithCoordinate:(CLLocationCoordinate2D)coordinate area:(NSString *)area address:(NSString *)address;
+ (KSGeoLocation *)addGeolocationWithCoordinate:(CLLocationCoordinate2D)coordinate area:(NSString *)area address:(NSString *)address Id:(NSNumber*)locationId;

+ (void)taxisNearCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius completion:(KSDALCompletionBlock)completionBlock;

+ (void)vehiclesNearCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius type:(KSVehicleType)type limit:(int)limit completion:(KSDALCompletionBlock)completionBlock;

+ (KSGeoLocation *)locationsWithLocationID:(NSNumber *)locId;

+(void) searchServerwithQuery:(NSString*)query completion:(KSDALCompletionBlock)completionBlock;

+(KSGeoLocation*)geolocationWithLandmark:(NSNumber *)lat Longitude:(NSNumber*)lon;
@end
