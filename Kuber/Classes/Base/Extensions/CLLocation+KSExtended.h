//  CLLocation+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

extern NSString *KSStringFromLatLng(CLLocationDegrees latitude, CLLocationDegrees longitude);

extern NSString *KSStringFromCoordinate(CLLocationCoordinate2D coordinate);

@interface CLLocation (KSExtended)

+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate;

+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (NSString *)stringifyCoordinate;

@end

