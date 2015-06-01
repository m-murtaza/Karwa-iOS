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
@class CLPlacemark;

typedef CLPlacemark KSPlacemark;
typedef void (^KSPlacemarkCompletionBlock)(KSPlacemark *);
typedef void (^KSPlacemarkListCompletionBlock)(NSArray *);

@interface KSLocationManager : NSObject

+ (instancetype)instance;

+ (CLLocation *)stop;

+ (CLLocation *)start;

+ (CLLocation *)location;

+ (CLPlacemark *)placemark;

+ (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion;

- (CLLocation *)stop;

- (CLLocation *)start;

- (CLLocation *)location;

- (CLPlacemark *)placemark;

- (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion;

- (void)placemarkForLocation:(CLLocation *)location completion:(KSPlacemarkCompletionBlock)completion;

- (void)nearestPlacemarksCountry:(NSString *)country searchQuery:(NSString *)address completion:(KSPlacemarkListCompletionBlock)completion;

@end
