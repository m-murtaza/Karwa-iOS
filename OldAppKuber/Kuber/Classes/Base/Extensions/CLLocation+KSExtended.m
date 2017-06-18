//
//  CLLocation+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "CLLocation+KSExtended.h"

NSString *KSStringFromLatLng(CLLocationDegrees latitude, CLLocationDegrees longitude) {
    return [NSString stringWithFormat:@"%0.3fN, %0.3fE", latitude, longitude];
}

NSString *KSStringFromCoordinate(CLLocationCoordinate2D coordinate) {
    return KSStringFromLatLng(coordinate.latitude, coordinate.longitude);
}

@implementation CLLocation (KSExtended)

+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate {
    return (coordinate.latitude && coordinate.longitude);
}

+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self isValidCoordinate:coordinate]) {
        return [[self alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
    return nil;
}

- (NSString *)stringifyCoordinate {

    return KSStringFromCoordinate(self.coordinate);
}

@end

