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
#import "AppUtils.h"

#define UPDATE_TEXT @"Taxi status last updated on %@"
#define ARRIVE_THRESHOLD 1.0     //For less then 60 second ETA it will show Arrived.


@interface KSTrackTaxiController () <MKMapViewDelegate>
{
    KSVehicleTrackingInfo *taxiInfo;
   // MKUserLocation *passengerLocation;
}

@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) IBOutlet UILabel *lblDistance;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) IBOutlet UILabel *lblUpdate;
@property (nonatomic, weak) IBOutlet UILabel *lblAway;

@end


@implementation KSTrackTaxiController

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setMapParameters];
    [self updateTaxiStatusUpdateLabel];
    
    [self updateNavigationTitle];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Where is my ride"];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self updateMapRegion];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Private Functions

-(void) updateNavigationTitle
{
    self.navigationItem.title = @"Where is my ride?";
}

-(void) updateTaxiStatusUpdateLabel
{
    NSDate *date = [NSDate date];
    [self.lblUpdate setText:[NSString stringWithFormat:UPDATE_TEXT,[date formatedDateForTaxiTracking]]];
}

-(BOOL) checkLocationAvaliblityAndShowAlert
{
    BOOL locationAvailable = TRUE;
    NSInteger locationStatus = [CLLocationManager authorizationStatus];
    
    if(locationStatus == kCLAuthorizationStatusRestricted || locationStatus == kCLAuthorizationStatusDenied || locationStatus == kCLAuthorizationStatusNotDetermined){
        locationAvailable = FALSE;
        KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [KSConfirmationAlert showWithTitle:nil
                                   message:@"Location services are disabled. Please enable location services."
                                  okAction:okAction];
    }
    return locationAvailable;
}

-(void) addPickupAnnotation
{
    MKPointAnnotation *pickupAnnotation = [[MKPointAnnotation alloc] init];
    pickupAnnotation.coordinate = CLLocationCoordinate2DMake([_trip.pickupLat doubleValue], [_trip.pickupLon doubleValue]);
    [_mapView addAnnotation:pickupAnnotation];
}

-(void) setMapParameters
{
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    [self.mapView setShowsUserLocation: YES];
    
    [self addPickupAnnotation];
    [self fetchTaxiInfo:nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                     target:self selector:@selector(fetchTaxiInfo:) userInfo:nil repeats:YES];
}

- (void) fetchTaxiInfo:(NSTimer *)t
{
    __block KSTrackTaxiController *me = self;
    
    [KSDAL trackTaxiWithTaxiNo:self.trip.taxi.number
                         JobID:self.trip.jobId
                    completion:^(KSAPIStatus status, id response) {
                        if (status == KSAPIStatusSuccess) {
                            
                            me->taxiInfo = (KSVehicleTrackingInfo *) response;
                            [me performSelectorOnMainThread:@selector(AnnimateVehicle) withObject:nil waitUntilDone:YES];
                            
                            [me updateTaxiStatusUpdateLabel];
                        }
                        else if(status == KSAPIStatusPassengerInTaxi){
                            
                            [me.timer invalidate];
                            me.timer = nil;
                            
                            KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
                                
                                [me.navigationController popViewControllerAnimated:YES];
                            }];
                            me.trip.status = [NSNumber numberWithInt:KSAPIStatusPassengerInTaxi];
                            [KSConfirmationAlert showWithTitle:@"Trip started"
                                                       message:@"We wish you a pleasant trip"
                                                      okAction:okAction
                                                  cancelAction:nil];
                            }
                    }];
}

-(KSVehicleTrackingAnnotation*) vehicleAnnotation:(NSArray*) annotatios
{
    KSVehicleTrackingAnnotation *vAnnotation = nil;
    
    for (id annotation in annotatios) {
        if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
            vAnnotation = annotation;
            break;
        }
    }
    return vAnnotation;
}

-(void) AnnimateVehicle
{
    KSVehicleTrackingAnnotation *annotation = [self vehicleAnnotation:_mapView.annotations];
    if(annotation == nil)
    {
        KSVehicleTrackingAnnotation *taxiAnnotation = [KSVehicleTrackingAnnotation annotationWithTrackingInfo:taxiInfo];
        [self.mapView addAnnotation:taxiAnnotation];
        [self updateMapRegion];
        [self updateETA:taxiInfo.currentETA];
    }
    else
    {
        KSVehicleAnnotationView *annotationView = (KSVehicleAnnotationView*)[_mapView viewForAnnotation:annotation];
        if(annotationView != nil)
        {
        
        [annotationView.imgView updateBearing:(CGFloat)taxiInfo.bearing
                                   Completion:^{
                                       
                                       [UIView animateWithDuration:3
                                                        animations:^{
                                                            
                                                            annotation.coordinate = taxiInfo.coordinate;
                                                            annotation.trackingInfo = taxiInfo;
                                                        }
                                        completion:^(BOOL finished) {
                                            if(finished)
                                                [self updateMapRegion];
                                                [self updateETA:taxiInfo.currentETA];

                                        }];
                                   }];
        }
        else
        {
            [self updateMapRegion];
            [self updateETA:taxiInfo.currentETA];
        }
    }
}

-(void) updateMapRegion
{
    if(taxiInfo != nil && _trip != nil)
    {
        CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake([_trip.pickupLat doubleValue], [_trip.pickupLon doubleValue]);
        if(CLLocationCoordinate2DIsValid(taxiInfo.coordinate) && CLLocationCoordinate2DIsValid(pickup))
        {
            [_mapView setCenterCoordinate:pickup];
            
            const CGFloat padding = 2.5; // 20%
            CGFloat latDelta = padding * fabs(pickup.latitude - taxiInfo.coordinate.latitude) * 2.0;
            CGFloat lonDelta = padding * fabs(pickup.longitude - taxiInfo.coordinate.longitude) * 2.0;
            MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
            MKCoordinateRegion region = MKCoordinateRegionMake(pickup, span);
            [self.mapView setRegion:region animated:YES];
        }
    }
}
//TODO: Remove this function after testing.
//-(void) updateMapAnnotation
//{
//   
//    if (passengerLocation && taxiInfo) {
//        KSVehicleTrackingAnnotation *taxiAnnotation = [KSVehicleTrackingAnnotation annotationWithTrackingInfo:taxiInfo];
//        if (CLLocationCoordinate2DIsValid(taxiInfo.coordinate) && CLLocationCoordinate2DIsValid(passengerLocation.coordinate)) {
//            
//            NSArray *previusAnnotations = self.mapView.annotations;
//            for (id annotation in previusAnnotations) {
//                if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
//                    [self.mapView removeAnnotation:annotation];
//                }
//            }
//            [self.mapView setCenterCoordinate:passengerLocation.coordinate];
//            [self.mapView addAnnotation:taxiAnnotation];
//
//            const CGFloat padding = 2.5; // 20%
//            CGFloat latDelta = padding * fabs(passengerLocation.coordinate.latitude - taxiAnnotation.coordinate.latitude) * 2.0;
//            CGFloat lonDelta = padding * fabs(passengerLocation.coordinate.longitude - taxiAnnotation.coordinate.longitude) * 2.0;
//            MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
//            MKCoordinateRegion region = MKCoordinateRegionMake(passengerLocation.coordinate, span);
//            [self.mapView setRegion:region];
//
//            [self updateETA:taxiAnnotation.trackingInfo.currentETA];
//            
//            //[self updateDistance:passengerLocation.location.coordinate TaxiLocation:taxiAnnotation.coordinate];
//        }
//    }
//}

-(void) updateETA:(NSInteger) eTA
{
    float minEta = (float)eTA / 60.0;
    
    if(minEta > ARRIVE_THRESHOLD && ![self.lblDistance.text isEqualToString:@"ARRIVED"])
    {
        self.lblDistance.text = [NSString stringWithFormat:@"%.0f Min",ceil(minEta)];
    }
    else
    {
        self.lblDistance.text = @"ARRIVED";
        self.lblAway.hidden = TRUE;
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
    [self checkLocationAvaliblityAndShowAlert];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
   
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    else if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
        
        static NSString *trackingIdentifier = @"VehicleTracking";
        KSVehicleAnnotationView *annotationVehicle = (KSVehicleAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:trackingIdentifier];
        if(annotationVehicle == nil)
        {
            annotationVehicle = [[KSVehicleAnnotationView alloc] initWithAnnotation:annotation];
        }
        else
        {
            annotationVehicle.annotation = annotation;
        }
        return annotationVehicle;
    }
    else if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *pickupIdentifier = @"PickupLocation";
        MKAnnotationView *annotationPickupView = [_mapView dequeueReusableAnnotationViewWithIdentifier:pickupIdentifier];
        if(annotationPickupView == nil)
            annotationPickupView = [[MKAnnotationView alloc] init];
        annotationPickupView.image = [UIImage imageNamed:@"pin.png"];
        annotationPickupView.canShowCallout = FALSE;
        return annotationPickupView;
    }
    return nil;
}

@end
