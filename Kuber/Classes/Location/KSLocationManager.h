//
//  KSLocationManager.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class CLLocationManager;
//@class CLPlacemark;

@class KSGeoLocation;

//typedef CLPlacemark KSPlacemark;
typedef void (^KSPlacemarkCompletionBlock)(KSGeoLocation *geolocation);
typedef void (^KSPlacemarkListCompletionBlock)(NSArray *placemarks);

@interface KSLocationManager : NSObject

+ (instancetype)instance;

+ (CLLocation *)stop;

+ (CLLocation *)start;

+ (CLLocation *)location;

//+ (CLPlacemark *)placemark;

+ (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion;

+ (void)placemarkForLocation:(CLLocation *)location completion:(KSPlacemarkCompletionBlock)completion;

+ (void)placemarkForCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkCompletionBlock)completion;

//+ (void)nearestPlacemarksInCountry:(NSString *)country searchQuery:(NSString *)address completion:(KSPlacemarkListCompletionBlock)completion;

- (CLLocation *)stop;

- (CLLocation *)start;

- (CLLocation *)location;

//- (CLPlacemark *)placemark;

- (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion;

- (void)placemarkForLocation:(CLLocation *)location completion:(KSPlacemarkCompletionBlock)completion;

//- (void)nearestPlacemarksInCountry:(NSString *)country searchQuery:(NSString *)address completion:(KSPlacemarkListCompletionBlock)completion;
- (void)placemarksMatchingQuery:(NSString *)query country:(NSString *)country completion:(KSPlacemarkListCompletionBlock)completionBlock;

- (void)locationWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkCompletionBlock)completionBlock;

@end
