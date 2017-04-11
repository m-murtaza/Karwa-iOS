//
//  KSVehicleAnnotationView.h
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "KSVehicleTrackingInfo.h"
#import "KSVehicleTrackingAnnotation.h"

@class KSVehicleTrackingAnnotation;

@interface KSVehicleAnnotationView : MKAnnotationView

+ (NSString *)reuseIdentifier;

- (instancetype)initWithAnnotation:(KSVehicleTrackingAnnotation *)annotation;

-(void) setUpdateVehicleIcon:(KSVehicleType) t;

@end
