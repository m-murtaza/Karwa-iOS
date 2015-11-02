//
//  KSTrackTaxiController.m
//  Kuber
//
//  Created by Asif Kamboh on 10/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTrackTaxiController.h"

//Frameworks
#import <MapKit/MapKit.h>

//Extensions
#import "MKMapView+KSExtensions.h"

//Classes
#import "KSVehicleTrackingAnnotation.h"
#import "KSVehicleAnnotationView.h"

@interface KSTrackTaxiController () <MKMapViewDelegate>
{
    KSVehicleTrackingInfo *taxiInfo;
    MKUserLocation *passengerLocation;
}

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@end


@implementation KSTrackTaxiController

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setMapParameters];
}



#pragma mark - Private Functions

-(void) setMapParameters
{
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    [self.mapView setShowsUserLocation: YES];
    
    //[self addAnotations];
    
    [KSDAL trackTaxiWithTaxiNo:self.taxiNo
                    completion:^(KSAPIStatus status, id response) {
        if (status == KSAPIStatusSuccess) {
            
            taxiInfo = (KSVehicleTrackingInfo *) response;
            [self updateMapAnnotation];
        }
        
        
    }];
}

-(void) updateMapAnnotation
{
    if (passengerLocation && taxiInfo) {
        KSVehicleTrackingAnnotation *taxiAnnotation = [KSVehicleTrackingAnnotation annotationWithTrackingInfo:taxiInfo];
        
        NSArray *previusAnnotations = self.mapView.annotations;
        for (id annotation in previusAnnotations) {
            if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        [self.mapView setCenterCoordinate:passengerLocation.coordinate];
        [self.mapView addAnnotation:taxiAnnotation];

        const CGFloat padding = 1.3; // 20%
        CGFloat latDelta = padding * fabs(passengerLocation.coordinate.latitude - taxiAnnotation.coordinate.latitude) * 2.0;
        CGFloat lonDelta = padding * fabs(passengerLocation.coordinate.longitude - taxiAnnotation.coordinate.longitude) * 2.0;
        MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
        MKCoordinateRegion region = MKCoordinateRegionMake(passengerLocation.coordinate, span);
        [self.mapView setRegion:region];

        [self.mapView ij_setVisibleRectToFitAllLoadedAnnotationsAnimated:YES];
    }
}

#pragma mark - MapView Delegate

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"");
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation     *)userLocation
{
    DLog(@"didUpdateUserLocation");
    passengerLocation = userLocation;
    [self updateMapAnnotation];

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
        annotationView = (KSVehicleAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[KSVehicleAnnotationView reuseIdentifier]];
        if (!annotationView) {
            annotationView = [[KSVehicleAnnotationView alloc] initWithAnnotation:annotation];
        }
        else {
            annotationView.annotation = annotation;
        }
    }
    return annotationView;
}

@end
