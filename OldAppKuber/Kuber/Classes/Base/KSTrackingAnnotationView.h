//
//  KSTrackingAnnotationView.h
//  Kuber
//
//  Created by Asif Kamboh on 11/2/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSVehicleAnnotationView.h"

typedef enum {
    
    KSAnnotationTypeTaxi = 0,
    KSAnnotationTypeUser = 1
}KSAnnotationType;

@interface KSTrackingAnnotationView : KSVehicleAnnotationView

- (instancetype)initWithAnnotation:(KSVehicleTrackingAnnotation *)annotation Type:(KSAnnotationType)annotationType;
-(void) SetAnnotationImageFor:(KSAnnotationType)annotationType;
@end
