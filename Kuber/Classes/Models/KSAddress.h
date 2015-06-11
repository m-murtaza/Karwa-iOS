//
//  KSAddress.h
//  Kuber
//
//  Created by Asif Kamboh on 6/9/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class CLPlacemark;

@interface KSAddress : NSObject

+ (instancetype)addressWithLandmark:(NSString *)landmark;
+ (instancetype)addressWithLocation:(CLLocation *)location;
+ (instancetype)addressWithCoordinate:(CLLocationCoordinate2D)coordinate;
+ (instancetype)addressWithLandmark:(NSString *)landmark coordinate:(CLLocationCoordinate2D)coordinate;
+ (instancetype)addressWithLandmark:(NSString *)landmark location:(CLLocation *)location;
+ (instancetype)addressWithPlacemark:(CLPlacemark *)placemark;

- (instancetype)initWithLandmark:(NSString *)landmark;
- (instancetype)initWithLocation:(CLLocation *)location;
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (instancetype)initWithLandmark:(NSString *)landmark coordinate:(CLLocationCoordinate2D)coordinate;
- (instancetype)initWithLandmark:(NSString *)landmark location:(CLLocation *)location;
- (instancetype)initWithPlacemark:(CLPlacemark *)placemark;

- (NSString *)landmark;

- (CLLocationCoordinate2D)coordinate;

- (CLLocation *)location;

@end
