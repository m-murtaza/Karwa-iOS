//
//  KSVehicleAnnotationView.m
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSVehicleAnnotationView.h"



@implementation KSVehicleAnnotationView

+ (NSString *)reuseIdentifier {
    return @"KSVehicleAnnotationView";
}

- (instancetype)initWithAnnotation:(KSVehicleTrackingAnnotation *)annotation {

    self = [super initWithAnnotation:annotation reuseIdentifier:[KSVehicleAnnotationView reuseIdentifier]];
    if (self) {

        self.canShowCallout = YES;
        self.draggable = NO;
        
        [self setUpdateVehicleIcon:annotation.trackingInfo.vehicleType];
    }
    return self;
}

-(void) setUpdateVehicleIcon:(KSVehicleType) t
{
    switch (t) {
        case KSCityTaxi:
        case KSAiportTaxi:
        case KSAirportSpare:
        case KSAiport7Seater:
        case KSSpecialNeedTaxi:
            self.image = [UIImage imageNamed:@"taxi-icon.png"];
            break;
        case KSStandardLimo:
        case KSCompactLimo:
            self.image = [UIImage imageNamed:@"limo-standard-icon.png"];
            break;
        case KSBusinessLimo:
            self.image = [UIImage imageNamed:@"limo-business-icon.png"];
            break;
        case KSLuxuryLimo:
            self.image = [UIImage imageNamed:@"limo-luxury-icon.png"];
            break;
        default:
            self.image = [UIImage imageNamed:@"taxi-icon.png"];
            break;
    }
}

- (void)setAnnotation:(KSVehicleTrackingAnnotation *)annotation
{
    
    [self setUpdateVehicleIcon:((KSVehicleTrackingAnnotation*)annotation).trackingInfo.vehicleType];
    [super setAnnotation:annotation];
    
}

@end
