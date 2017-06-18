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
        self.image = [UIImage imageNamed:@"1PxTransparent.png"];
        //[self setUpdateVehicleIcon:annotation.trackingInfo.vehicleType];
    }
    return self;
}

-(void) updateImage:(KSVehicleType)vType Bearing:(CGFloat)bearing
{
    if(_imgView == nil)
    {
        _imgView = [[KSUIImageViewAnnotation alloc] initWithImage:[self imageForVehicleType:vType] Bearing:bearing];
        [_imgView setFrame:CGRectMake(0.0, 0.0, 17.0, 31.0)];
        [self addSubview:_imgView];
    }
    else
    {
        [_imgView setImage:[self imageForVehicleType:vType]];
        [_imgView updateBearing:bearing Completion:^{
            
        }];
    }
    
}


-(UIImage*) imageForVehicleType:(KSVehicleType) vType
{
    UIImage *img = nil;
    
    switch (vType) {
        case KSCityTaxi:
        case KSAiportTaxi:
        case KSAirportSpare:
        case KSAiport7Seater:
        case KSSpecialNeedTaxi:
            img = [UIImage imageNamed:@"taxi-icon.png"];
            break;
        case KSStandardLimo:
            img = [UIImage imageNamed:@"limo-standard-icon.png"];
            break;
        case KSBusinessLimo:
            img = [UIImage imageNamed:@"limo-business-icon.png"];
            break;
        case KSLuxuryLimo:
            img = [UIImage imageNamed:@"limo-luxury-icon.png"];
            break;
        default:
            img = [UIImage imageNamed:@"taxi-icon.png"];
            break;
    }
    return img;
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
    //--[self setUpdateVehicleIcon:((KSVehicleTrackingAnnotation*)annotation).trackingInfo.vehicleType];
    
    //--self.image = [self.image imageRotatedByDegrees:(CGFloat)((KSVehicleTrackingAnnotation*)annotation).trackingInfo.bearing];
    
    //DLog(@"Bearing : %ld",(long)((KSVehicleTrackingAnnotation*)annotation).trackingInfo.bearing);
    
    [self updateImage:((KSVehicleTrackingAnnotation*)annotation).trackingInfo.vehicleType Bearing:(CGFloat)((KSVehicleTrackingAnnotation*)annotation).trackingInfo.bearing];
    
    [super setAnnotation:annotation];
    
}

@end
