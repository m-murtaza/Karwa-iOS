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
#import "KSTrackingAnnotationView.h"
#import "KSConfirmationAlert.h"

@interface KSTrackTaxiController () <MKMapViewDelegate>
{
    KSVehicleTrackingInfo *taxiInfo;
    MKUserLocation *passengerLocation;
    NSTimer *timer;
}

@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) IBOutlet UILabel *lblDistance;

@end


@implementation KSTrackTaxiController

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setMapParameters];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)dealloc
{
    //[super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

//-(void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    if ([self.mapView respondsToSelector:@selector(camera)]) {
//        MKMapCamera *newCamera = [[self.mapView camera] copy];
//        [newCamera setHeading:90.0]; // or newCamera.heading + 90.0 % 360.0
//        [self.mapView setCamera:newCamera animated:NO];
//    }
//}



#pragma mark - Private Functions

-(void) setMapParameters
{
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    [self.mapView setShowsUserLocation: YES];
    
    //[self addAnotations];
    
    [self fetchTaxiInfo:nil];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:61.0f
                                     target:self selector:@selector(fetchTaxiInfo:) userInfo:nil repeats:YES];
    
    
}

- (void) fetchTaxiInfo:(NSTimer *)t
{
    [KSDAL trackTaxiWithTaxiNo:self.trip.taxi.number
                         JobID:self.trip.jobId
                    completion:^(KSAPIStatus status, id response) {
                        if (status == KSAPIStatusSuccess) {
                            
                            taxiInfo = (KSVehicleTrackingInfo *) response;
                            [self performSelectorOnMainThread:@selector(updateMapAnnotation) withObject:nil waitUntilDone:YES];
                            
                            //[self updateMapAnnotation];
                        }
                        else if(status == KSAPIStatusPassengerInTaxi){
                            
                            
                            KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
                                
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            //[timer invalidate];
                            //timer = nil;
                            self.trip.status = [NSNumber numberWithInt:KSAPIStatusPassengerInTaxi];
                            [KSConfirmationAlert showWithTitle:@"Trip started"
                                                       message:@"We wish you a pleasant trip"
                                                      okAction:okAction
                                                  cancelAction:nil];
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

        const CGFloat padding = 2.5; // 20%
        CGFloat latDelta = padding * fabs(passengerLocation.coordinate.latitude - taxiAnnotation.coordinate.latitude) * 2.0;
        CGFloat lonDelta = padding * fabs(passengerLocation.coordinate.longitude - taxiAnnotation.coordinate.longitude) * 2.0;
        MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
        MKCoordinateRegion region = MKCoordinateRegionMake(passengerLocation.coordinate, span);
        [self.mapView setRegion:region];

        [self updateDistance:passengerLocation.location.coordinate TaxiLocation:taxiAnnotation.coordinate];
    }
}

-(void) updateDistance:(CLLocationCoordinate2D)passengerLoc TaxiLocation:(CLLocationCoordinate2D)taxiLocaiton
{
    CLLocation *passenger = [[CLLocation alloc] initWithLatitude:passengerLoc.latitude longitude:passengerLoc.longitude];
    CLLocation *taxi = [[CLLocation alloc] initWithLatitude:taxiLocaiton.latitude longitude:taxiLocaiton.longitude];
    
    CLLocationDistance meters = [passenger distanceFromLocation:taxi];
    
    if (meters > 1000) {
        self.lblDistance.text = [NSString stringWithFormat:@"%0.0f KM",meters/1000];
    }
    else {
        self.lblDistance.text = [NSString stringWithFormat:@"%0.0f M",meters];
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
   
    
    KSAnnotationType annotationType = KSAnnotationTypeUser;
    if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
        annotationType = KSAnnotationTypeTaxi;
    }
    
    MKAnnotationView *annotationView = nil;
    //if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
        annotationView = (KSTrackingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[KSTrackingAnnotationView reuseIdentifier]];
        if (!annotationView) {
            annotationView = [[KSTrackingAnnotationView alloc] initWithAnnotation:annotation Type:annotationType];
        }
        else {
            [(KSTrackingAnnotationView*)annotationView SetAnnotationImageFor:annotationType];
            annotationView.annotation = annotation;
            
        }
    //}
    return annotationView;
}

@end
