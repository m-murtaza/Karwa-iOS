//
//  KSTrackingAnnotationView.m
//  Kuber
//
//  Created by Asif Kamboh on 11/2/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSTrackingAnnotationView.h"

@implementation KSTrackingAnnotationView



- (instancetype)initWithAnnotation:(KSVehicleTrackingAnnotation *)annotation Type:(KSAnnotationType)annotationType
{
    self = [super initWithAnnotation:annotation reuseIdentifier:[KSVehicleAnnotationView reuseIdentifier]];
    if (self) {
        
        self.canShowCallout = YES;
        self.draggable = NO;
        switch (annotationType) {
            case KSAnnotationTypeTaxi:
                self.image = [UIImage imageNamed:@"taxiPin.png"];
                break;
            case KSAnnotationTypeUser:
                self.image = [UIImage imageNamed:@"myPin.png"];
                break;
            default:
                break;
        }
        
    }
    return self;
}


-(void) SetAnnotationImageFor:(KSAnnotationType)annotationType
{
    switch (annotationType) {
        case KSAnnotationTypeTaxi:
            self.image = [UIImage imageNamed:@"taxiPin.png"];
            break;
        case KSAnnotationTypeUser:
            self.image = [UIImage imageNamed:@"myPin.png"];
            break;
        default:
            break;
    }
}
@end
