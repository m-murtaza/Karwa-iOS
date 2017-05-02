//
//  KSBookingAnnotationManager.m
//  Kuber
//
//  Created by Muhammad Usman on 4/25/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSBookingAnnotationManager.h"
#import "KSVehicleTrackingAnnotation.h"
#import "KSVehicleAnnotationView.h"
//#import "UIImage+RotationMethods.h"
#import "KSDAL.h"

#define MAX_TAXI_ANNOTATIONS        (10)

@interface KSBookingAnnotationManager()
{
    //NSMutableArray *vehiclesAnnotations;
    CLLocationCoordinate2D lastCoordinate;
    double lastRadius;
    KSVehicleType lastVehicleType;
}

@end
@implementation KSBookingAnnotationManager

- (void)vehiclesAnnotationNearCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius type:(KSVehicleType)type completion:(KSBookingAnnotationCompletionBlock)completionBlock
{
    lastCoordinate = coordinate;
    lastRadius = radius;
    lastVehicleType = type;
    
    [KSDAL vehiclesNearCoordinate:coordinate
                           radius:radius
                             type:type
                            limit:MAX_TAXI_ANNOTATIONS
                       completion:^(KSAPIStatus status, NSArray * vehicles) {
                           NSMutableArray *vehiclesAnnotations = [NSMutableArray array];
        
                           for (int counter = 0; counter < vehicles.count; counter++) {
                               [vehiclesAnnotations addObject:[KSVehicleTrackingAnnotation annotationWithTrackingInfo:[vehicles objectAtIndex:counter]]];
                           }
                           completionBlock([NSArray arrayWithArray:vehiclesAnnotations]);
                       }];
}

-(void) updateVehicleInMap:(MKMapView*)mapView completion:(KSUpdateAnnotationCompletionBlock)completionBlock
{
    NSArray *annotations = mapView.annotations;
    NSArray *vAnnotations = [self vehicleAnnotations:annotations];   //vAnnotations, all annotation on map for Vehicle
    if(vAnnotations != nil && vAnnotations.count != 0)
    {
        [KSDAL vehiclesNearCoordinate:lastCoordinate
                               radius:lastRadius
                                 type:lastVehicleType
                                limit: MAX_TAXI_ANNOTATIONS
                           completion:^(KSAPIStatus status, NSArray * vehicles) {
                               
                               if(status == KSAPIStatusSuccess)
                               {
                                   NSArray *addVehicleAnnotation = [self updateAnnotation:vehicles
                                                                           MapAnnotations:vAnnotations
                                                                                  MapView:mapView];
                                   
                                   NSArray *removeVehicleAnnotation = [self listDeleteAnnotation:vehicles MapAnnotations:vAnnotations];
                                   completionBlock(addVehicleAnnotation,removeVehicleAnnotation);
                               }
                           }];
    }
}

//-(void) updateVehicleAnnotation:(NSArray*)annotations completion:(KSUpdateAnnotationCompletionBlock)completionBlock
//{
//    NSArray *vAnnotations = [self vehicleAnnotations:annotations];
//    if(vAnnotations != nil && vAnnotations.count != 0)
//    {
//        [KSDAL vehiclesNearCoordinate:lastCoordinate
//                               radius:lastRadius
//                                 type:lastVehicleType
//                                limit: MAX_TAXI_ANNOTATIONS
//                           completion:^(KSAPIStatus status, NSArray * vehicles) {
//                               
//                               NSArray *addVehicleAnnotation = [self updateAnnotation:vehicles MapAnnotations:vAnnotations];
//                               NSArray *removeVehicleAnnotation = [self listDeleteAnnotation:vehicles MapAnnotations:vAnnotations];
//                               completionBlock(addVehicleAnnotation,removeVehicleAnnotation);
//                               
//                           }];
//    }
//}

-(NSArray*) listDeleteAnnotation:(NSArray*)vehicles MapAnnotations:(NSArray*)mapAnnotations
{
    NSMutableArray *vehiclesAnnotations = [NSMutableArray array];
    for(KSVehicleTrackingAnnotation *annotation in mapAnnotations)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehicleId = %@",annotation.trackingInfo.vehicleId];
        NSArray *filteredAnnotations = [vehicles filteredArrayUsingPredicate:predicate];
        if(filteredAnnotations == nil || filteredAnnotations.count == 0)
        {
            [vehiclesAnnotations addObject:annotation];
        }
    }
    return vehiclesAnnotations;
}

//Update location of present annotation and return list of new annotation.
-(NSArray*) updateAnnotation:(NSArray*) vehicles MapAnnotations:(NSArray*)mapAnnotations MapView:(MKMapView*)mapView
{
    NSMutableArray *vehiclesAnnotations = [NSMutableArray array];
    for(KSVehicleTrackingInfo *vehicle in vehicles)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"trackingInfo.vehicleId = %@", vehicle.vehicleId];
        NSArray *filteredAnnotations = [mapAnnotations filteredArrayUsingPredicate:predicate];
        if(filteredAnnotations != nil && filteredAnnotations.count != 0)
        {
            KSVehicleTrackingAnnotation *vAnnotation = [filteredAnnotations objectAtIndex:0];
            KSVehicleAnnotationView *a = (KSVehicleAnnotationView*)[mapView viewForAnnotation:vAnnotation];
        
            [a.imgView updateBearing:(CGFloat)vehicle.bearing
                          Completion:^{
                              
                              [UIView animateWithDuration:3
                                               animations:^{
                                                   KSVehicleTrackingAnnotation *vAnnotation = [filteredAnnotations objectAtIndex:0];
                                                   vAnnotation.coordinate = vehicle.coordinate;
                                                   vAnnotation.trackingInfo = vehicle;
                                               }];
                              
                          }];
        }
        else
        {
            [vehiclesAnnotations addObject:[KSVehicleTrackingAnnotation annotationWithTrackingInfo:vehicle]];
        }
    }
    
    return vehiclesAnnotations;
}

//Retruns vehicleAnnotations from all map annotations.
-(NSArray*) vehicleAnnotations:(NSArray*) annotatios
{
    NSMutableArray *vAnnotations = [[NSMutableArray alloc] init];
    
    
    for (id annotation in annotatios) {
        if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
            [vAnnotations addObject:annotation];
        }
    }
    
    return [NSArray arrayWithArray:vAnnotations];
}

@end
