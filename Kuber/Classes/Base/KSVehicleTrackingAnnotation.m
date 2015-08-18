//
//  KSVehicleTrackingAnnotation.m
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSVehicleTrackingAnnotation.h"

#import "KSVehicleTrackingInfo.h"

@implementation KSVehicleTrackingAnnotation

+ (instancetype)annotationWithTrackingInfo:(KSVehicleTrackingInfo *)trackingInfo {

    return [[self alloc] initWithTrackingInfo:trackingInfo];
}

- (instancetype)initWithTrackingInfo:(KSVehicleTrackingInfo *)trackingInfo {

    self = [super init];
    if (self) {

        self.coordinate = trackingInfo.coordinate;

        _trackingInfo = trackingInfo;
    }
    return self;
}

@end
