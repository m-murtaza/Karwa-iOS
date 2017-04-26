//
//  KSBookingAnnotationManager.h
//  Kuber
//
//  Created by Muhammad Usman on 4/25/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KSBookingAnnotationCompletionBlock)(NSArray *vehicleAnnotation);
typedef void(^KSUpdateAnnotationCompletionBlock)(NSArray *vehicleAddAnnotation,NSArray *vehicleRemoveAnnotation);

@interface KSBookingAnnotationManager : NSObject

- (void)vehiclesAnnotationNearCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius type:(KSVehicleType)type completion:(KSBookingAnnotationCompletionBlock)completionBlock;

-(void) updateVehicleAnnotation:(NSArray*)annotations completion:(KSUpdateAnnotationCompletionBlock)completionBlock;

@end
