//
//  KSPinAnnotationView.m
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSPinAnnotationView.h"

@implementation KSPinAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)identifierForType:(KSAnnotationType)annotationType {
    if (KSAnnotationTypePickup == annotationType) {
        return @"KSPickupPinView";
    }
    return @"KSDropoffPinView";
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation type:(KSAnnotationType)annotationType {
    self = [super initWithAnnotation:annotation reuseIdentifier:[KSPinAnnotationView identifierForType:annotationType]];

    if (self) {

        UIImage *leftCalloutIcon;
        MKPinAnnotationColor pinColor;
        if (KSAnnotationTypePickup == annotationType) {
            pinColor = MKPinAnnotationColorGreen;
            leftCalloutIcon = [UIImage imageNamed:@"location.png"];
        }
        else {
            pinColor = MKPinAnnotationColorRed;
            leftCalloutIcon = [UIImage imageNamed:@"destination.png"];
        }

        self.canShowCallout = YES;
        self.animatesDrop = YES;
        self.draggable = YES;
        self.pinColor = pinColor;

        UIImageView *leftIcon = [[UIImageView alloc] initWithImage:leftCalloutIcon];
        leftIcon.frame = CGRectMake(0, 0, leftCalloutIcon.size.width, leftCalloutIcon.size.height);
        self.leftCalloutAccessoryView = leftIcon;
    
    }

    return self;
}

@end
