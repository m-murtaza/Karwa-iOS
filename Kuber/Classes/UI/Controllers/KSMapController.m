//
//  KSMapController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "KSMapController.h"
#import "KSLocationManager.h"
#import "KSReadOnlyTextField.h"
#import "KSPointAnnotation.h"
#import "KSPinAnnotationView.h"

#import "KSAddressPickerController.h"
#import "KSBookingConfirmationController.h"

#import "KSGeoLocation.h"

#import "KSDAL+Location.h"

#import "KSVehicleTrackingInfo.h"
#import "KSVehicleTrackingAnnotation.h"
#import "KSVehicleAnnotationView.h"

#import "KSAddress.h"

#import <objc/objc.h>
#import <objc/runtime.h>

#define METERS_PER_MILE         (1609.344)
#define MAP_REGION_VERTEX       (1.5 * METERS_PER_MILE)
#define MAX_TAXI_ANNOTATIONS    (10)

NSString * const KSPickupAnnotationTitle = @"Pickup Address";
NSString * const KSDropoffAnnotationTitle = @"Dropoff Address";
NSString * const KSDropoffTextPlaceholder = @"Tap for a second on map (Optional)";

@interface KSMapController ()<UITextFieldDelegate, MKMapViewDelegate, KSAddressPickerDelegate>
{
    BOOL _isLocationsSyncComplete;
    BOOL _isRegionDefined;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) KSPointAnnotation *pickupPoint;
@property (nonatomic, strong) KSPointAnnotation *dropoffPoint;

@property (nonatomic, strong) NSArray *places;

@property (weak, nonatomic) IBOutlet KSReadOnlyTextField *txtPickupAddress;

@property (weak, nonatomic) IBOutlet KSReadOnlyTextField *txtDropoffAddress;


- (IBAction)onClickDropoffAddress:(id)sender;

- (IBAction)onClickPickupAddress:(id)sender;

@end

@implementation KSMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
//    _mapView.showsUserLocation = NO;

    MKUserTrackingBarButtonItem *button = [[MKUserTrackingBarButtonItem alloc] initWithMapView:_mapView];
    self.navigationItem.rightBarButtonItem = button;
    
    self.mapView.delegate = self;

    [self.txtPickupAddress addTarget:self action:@selector(onAddressChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txtDropoffAddress addTarget:self action:@selector(onAddressChange:) forControlEvents:UIControlEventEditingChanged];

    self.txtPickupAddress.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];

    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressMapView:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];

    __block KSMapController *me = self;

    [KSDAL syncLocationsWithCompletion:^(KSAPIStatus status, id response) {

        _isLocationsSyncComplete = YES;
        if (me.pickupPoint) {
            [me updateAddressField:me.txtPickupAddress annotation:me.pickupPoint];
        }

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [KSLocationManager start];

//    [KSLocationManager placemarkWithBlock:^(KSGeoLocation *placemark) {
//        CLLocation *location = placemark.location;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 4.0 * METERS_PER_MILE, 4.0 * METERS_PER_MILE);
//        [_mapView setRegion:viewRegion animated:YES];
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [KSLocationManager stop];
}

- (KSPointAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title offset:(CGFloat)offset {
    
    KSPointAnnotation *annotation = [[KSPointAnnotation alloc] init];

    annotation.title = title;
    
    CLLocationCoordinate2D latLng = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    latLng.latitude +=  offset;
    latLng.longitude += offset;

    annotation.coordinate = latLng;
    
    [self.mapView addAnnotation:annotation];
    
    return annotation;
}

- (KSPointAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {

    return [self annotationWithCoordinate:coordinate title:title offset:0.];
}


#pragma mark -
#pragma mark - Text field events

- (void)onAddressChange:(UITextField *)textfield {

    NSLog(@"%s: %@", __func__, textfield.text);
    if (!textfield.text.length) {
        KSPointAnnotation *annotation;
        if (textfield == self.txtPickupAddress) {
            annotation = self.pickupPoint;
            self.pickupPoint = nil;
        } else {
            annotation = self.dropoffPoint;
            self.dropoffPoint = nil;
        }
        [self.mapView removeAnnotation:annotation];
    }
}

#pragma mark -
#pragma mark - Address picker delegate

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location {
    NSLog(@"%s: address=%@, %@", __func__, address, location);
    UITextField *addressField = nil;
    KSPointAnnotation *annotation = nil;

//    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    _mapView.userTrackingMode = MKUserTrackingModeNone;
    _mapView.showsUserLocation = NO;

    if ([picker.pickerId isEqualToString:KSPickerIdForDropoffAddress]) {
        addressField = self.txtDropoffAddress;
        if (!self.dropoffPoint) {
            self.dropoffPoint = [self annotationWithCoordinate:location.coordinate title:KSDropoffAnnotationTitle];
        }
        annotation = self.dropoffPoint;
        self.txtDropoffAddress.placeholder = KSDropoffTextPlaceholder;
    }
    else {
        addressField = self.txtPickupAddress;
        if (!self.pickupPoint) {
            self.pickupPoint = [self annotationWithCoordinate:location.coordinate title:KSPickupAnnotationTitle];
        }
        annotation = self.pickupPoint;
    }
    if (location) {
        addressField.text = address;
        annotation.title = address;
//        annotation.subtitle = address;
        annotation.coordinate = location.coordinate;
        annotation.isInvalid = NO;
        [self.mapView selectAnnotation:annotation animated:YES];
        [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
        [self defineMapRegionWithCenter:annotation.coordinate];

    }
    else {
        addressField.text = [NSString stringWithFormat:@"\u26A0 %@", address];
        annotation.isInvalid = YES;
    }
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[KSAddressPickerController class]]) {

        __block KSAddressPickerController *controller = (KSAddressPickerController *)segue.destinationViewController;
        controller.pickerId = segue.identifier;
        controller.delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[KSBookingConfirmationController class]]) {

        KSBookingConfirmationController *controller = (KSBookingConfirmationController *)segue.destinationViewController;
        controller.pickupAddress = [KSAddress addressWithLandmark:self.txtPickupAddress.text coordinate:self.pickupPoint.coordinate];
        if (self.dropoffPoint) {
            controller.dropoffAddress = [KSAddress addressWithLandmark:self.txtDropoffAddress.text coordinate:self.dropoffPoint.coordinate];
        }
        else {
            controller.dropoffAddress = [KSAddress addressWithLandmark:self.txtDropoffAddress.text];
        }

        UIButton *btn = (UIButton *)sender;
        controller.showsDatePicker = (btn.tag > 0);
    }
}

- (void)updateAddressField:(UITextField *)addressField annotation:(MKPointAnnotation *)annotation {

    NSString *address = KSStringFromCoordinate(annotation.coordinate);
    addressField.text = address;
    annotation.title = address;
//    annotation.subtitle = address;
    
    [[KSLocationManager instance] locationWithCoordinate:annotation.coordinate completion:^(KSGeoLocation *geolocation) {
        NSString *address = geolocation ? geolocation.address : KSStringFromCoordinate(annotation.coordinate);
        addressField.text = address;
        annotation.title = address;
//        annotation.subtitle = address;
        NSLog(@"%@", address);
    }];
}

- (void)updatePlacemarkForAnnotation:(MKPointAnnotation *)annotation {

    __block UITextField *addressField = nil;
    if (annotation == self.pickupPoint) {
        addressField = self.txtPickupAddress;
    }
    else if (annotation == self.dropoffPoint) {
        addressField = self.txtDropoffAddress;
    }
    else {
        return;
    }
    [self updateAddressField:addressField annotation:annotation];
}

- (void)updateTaxisInCurrentRegion {
    
    if (!_isRegionDefined) {
        return;
    }
    CLLocationCoordinate2D center = _mapView.centerCoordinate;
    CLLocationCoordinate2D left = [_mapView convertPoint:CGPointMake(0, _mapView.frame.size.height / 2.0) toCoordinateFromView:_mapView];
    CLLocationDistance radius = [[CLLocation locationWithCoordinate:center] distanceFromLocation:[CLLocation locationWithCoordinate:left]];
    
    [KSDAL taxisNearCoordinate:center radius:radius completion:^(KSAPIStatus status, NSArray * vehicles) {
        
        NSMutableArray *vehiclesAnnotations = [NSMutableArray array];
        for (int counter = 0; counter < vehicles.count && counter < MAX_TAXI_ANNOTATIONS; counter++) {

            [vehiclesAnnotations addObject:[KSVehicleTrackingAnnotation annotationWithTrackingInfo:[vehicles objectAtIndex:counter]]];
        }
        NSArray *previusAnnotations = self.mapView.annotations;
        for (id annotation in previusAnnotations) {
            if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        [self.mapView addAnnotations:vehiclesAnnotations];
        
    }];
}

- (void)defineMapRegionWithCenter:(CLLocationCoordinate2D)center {

    if (!_isRegionDefined) {
        _isRegionDefined = YES;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, MAP_REGION_VERTEX, MAP_REGION_VERTEX);
        
        [_mapView setRegion:viewRegion animated:YES];
    }
}

#pragma mark -
#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    mapView.showsUserLocation = NO;
//    mapView.userTrackingMode = MKUserTrackingModeNone;

    if (!self.pickupPoint) {
        self.pickupPoint = [self annotationWithCoordinate:userLocation.location.coordinate title:KSPickupAnnotationTitle];
        [self updatePlacemarkForAnnotation:self.pickupPoint];
        [self defineMapRegionWithCenter:userLocation.location.coordinate];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    [self updateTaxisInCurrentRegion];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[KSPointAnnotation class]]) {
        MKAnnotationView *pin = nil;
        KSAnnotationType annotationType = (annotation == self.pickupPoint) ? KSAnnotationTypePickup : KSAnnotationTypeDropoff;
        NSString *pinReuseIdentifier = [KSPinAnnotationView identifierForType:annotationType];
        
        pin = [self.mapView dequeueReusableAnnotationViewWithIdentifier:pinReuseIdentifier];
        
        if (!pin) {
            pin = [[KSPinAnnotationView alloc] initWithAnnotation:annotation type:annotationType];
        }
        else {
            pin.annotation = annotation;
        }
        annotationView = pin;
    }
    else if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    NSLog(@"%s", __func__);
    if (newState == MKAnnotationViewDragStateEnding) {
        if ([view.annotation isKindOfClass:[KSPointAnnotation class]]) {
            KSPointAnnotation *annotation =  (KSPointAnnotation *)view.annotation;
            annotation.isInvalid = NO;
        }
        [self updatePlacemarkForAnnotation:view.annotation];
    }
}

#pragma mark -
#pragma mark - Event handlers

- (void)onLongPressMapView:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    KSPointAnnotation *annotation = nil;
    UITextField *addressField;
    MKMapView *mapView = self.mapView;

    if (!self.pickupPoint) {
        annotation = self.pickupPoint = [self annotationWithCoordinate:touchMapCoordinate title:KSPickupAnnotationTitle];
        addressField = self.txtPickupAddress;
        self.txtDropoffAddress.placeholder = KSDropoffTextPlaceholder;
    }
    else {
        if (!self.dropoffPoint) {
            self.dropoffPoint = [self annotationWithCoordinate:touchMapCoordinate title:KSDropoffAnnotationTitle];
            annotation = self.dropoffPoint;
            addressField = self.txtDropoffAddress;
        }
//        else {
//            [self.dropoffPoint setCoordinate:touchMapCoordinate];
//        }
    }

    annotation.isInvalid = NO;

    if (annotation) {

        [self updateAddressField:addressField annotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];

        [self defineMapRegionWithCenter:annotation.coordinate];

    }
}

- (void)handleAddressClick:(KSPointAnnotation *)annotation pointId:(NSString *)pointId {
    
    if (annotation && annotation.isValid) {

        [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
    else {
        KSAddressPickerController *addressPicker = [UIStoryboard addressPickerController];
        addressPicker.pickerId = pointId;
        addressPicker.delegate = self;
        [self.navigationController pushViewController:addressPicker animated:YES];
    }
}

- (IBAction)onClickPickupAddress:(id)sender {

    [self handleAddressClick:self.pickupPoint pointId:KSPickerIdForPickupAddress];
}

- (IBAction)onClickDropoffAddress:(id)sender {

    [self handleAddressClick:self.dropoffPoint pointId:KSPickerIdForDropoffAddress];
}

@end
