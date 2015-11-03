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
        self.image = [UIImage imageNamed:@"taxi-icon.png"];
    }
    return self;
}

- (void)setAnnotation:(KSVehicleTrackingAnnotation *)annotation {

    [super setAnnotation:annotation];
    
}

@end
