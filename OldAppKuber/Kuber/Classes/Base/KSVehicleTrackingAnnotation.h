//
//  KSVehicleTrackingAnnotation.h
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

@class KSVehicleTrackingInfo;

@interface KSVehicleTrackingAnnotation : MKPointAnnotation

@property (nonatomic, strong) KSVehicleTrackingInfo *trackingInfo;

+ (instancetype)annotationWithTrackingInfo:(KSVehicleTrackingInfo *)trackingInfo;

- (instancetype)initWithTrackingInfo:(KSVehicleTrackingInfo *)trackingInfo;

@end
