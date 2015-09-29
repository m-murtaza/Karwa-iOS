//
//  KSBookingMapController.m
//  Kuber
//
//  Created by Asif Kamboh on 9/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingMapController.h"

//Utilities
#import "KSLocationManager.h"

@interface KSBookingMapController ()
{
  
    //This will identify if map is loaded for the first time.
    BOOL mapLoadForFirstTime;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *lblLocationLandMark;


@end

@implementation KSBookingMapController

-(void) viewDidLoad
{
    
    [super viewDidLoad];

    mapLoadForFirstTime = TRUE;
    
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
}

#pragma mark - Private Function

-(void) setMapRegionToUserCurrentLocation
{
    //Zoom map to users current location
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.00001;
    span.longitudeDelta = 0.00001;
    
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    region.span = span;
    region.center = location;
    
    [_mapView setRegion:region animated:TRUE];
    [_mapView regionThatFits:region];
}

-(void) setPickupLocationLblText
{

    //Firstly only show the lat long
    [self.lblLocationLandMark setText:[NSString stringWithFormat:@"%f - %f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude]];
    
    //Then reverse geocode the lat long
    [[KSLocationManager instance] locationWithCoordinate:self.mapView.centerCoordinate completion:^(KSGeoLocation *geolocation) {
        
        if (geolocation.address) {
            DLog(@"Address is found for %f - %f is %@",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude,geolocation.address);

            
            [self.lblLocationLandMark setText:geolocation.address];
        }
        else {
        
            DLog(@"Address is not found for %f - %f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
        }
        
        
    }];
    
}

#pragma mark - MapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation     *)userLocation
{
    if (mapLoadForFirstTime) {
        mapLoadForFirstTime = FALSE;
        [self setMapRegionToUserCurrentLocation];
    }
    
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated");
    
    [self setPickupLocationLblText];
    
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    //37.7738398,-122.4188001
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.7738398 longitude:-122.4188001];
//    NSLog(@"%@",location);
//    CLGeocoder  *geocoder = [[CLGeocoder alloc] init];
//    
//    __block UILabel *lbl = self.lbl;
//    
//    [geocoder reverseGeocodeLocation:location completionHandler:
//     ^(NSArray* placemarks, NSError* error){
//         NSLog(@"%@",placemarks);
//         if ([placemarks count] > 0)
//         {
//             MKPlacemark *placemark = [placemarks objectAtIndex:0];
//             
//             // Add a More Info button to the annotation's view.
//             
//             lbl.text = placemark.name;
//             
//         }
//     }];
    
}



@end
