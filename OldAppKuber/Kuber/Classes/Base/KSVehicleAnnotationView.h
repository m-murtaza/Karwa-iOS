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
#import "KSUIImageViewAnnotation.h"
///#import "UIImage+RotationMethods.h"

@class KSVehicleTrackingAnnotation;

@interface KSVehicleAnnotationView : MKAnnotationView

@property (nonatomic, strong) KSUIImageViewAnnotation *imgView;

+ (NSString *)reuseIdentifier;

- (instancetype)initWithAnnotation:(KSVehicleTrackingAnnotation *)annotation;

-(void) setUpdateVehicleIcon:(KSVehicleType) t;

-(void) updateImage:(KSVehicleType)vType  Bearing:(CGFloat)bearing;



@end
