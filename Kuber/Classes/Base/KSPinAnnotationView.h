//
//  KSPinAnnotationView.h
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {

    KSAnnotationTypePickup,
    KSAnnotationTypeDropoff
}
KSAnnotationType;

@interface KSPinAnnotationView : MKPinAnnotationView

@property (nonatomic, readonly) KSAnnotationType annotationType;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation type:(KSAnnotationType)annotationType;

+ (NSString *)identifierForType:(KSAnnotationType)annotationType;

@end
