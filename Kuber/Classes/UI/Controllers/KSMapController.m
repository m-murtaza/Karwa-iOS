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

#import "KSAddressPickerController.h"
#import "KSBookingConfirmationController.h"

#import "KSAddress.h"

#import <objc/objc.h>
#import <objc/runtime.h>

#define METERS_PER_MILE 1609.344

NSString * const KSPickupAnnotationTitle = @"Pickup Address";
NSString * const KSDropoffAnnotationTitle = @"Dropoff Address";
NSString * const KSDropoffTextPlaceholder = @"Tap for a second on map (Optional)";

@implementation KSPointAnnotation

@end

@interface KSMapController ()<UITextFieldDelegate, MKMapViewDelegate, KSAddressPickerDelegate>

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
    
    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressMapView:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [KSLocationManager start];

    [KSLocationManager placemarkWithBlock:^(CLPlacemark *placemark) {
//        CLLocation *location = placemark.location;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 4.0 * METERS_PER_MILE, 4.0 * METERS_PER_MILE);
//        [_mapView setRegion:viewRegion animated:YES];
    }];
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
        annotation.subtitle = address;
        annotation.coordinate = location.coordinate;
        annotation.isInvalid = NO;
        [self.mapView selectAnnotation:annotation animated:YES];
        [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
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
        CLLocationCoordinate2D coordinate = self.pickupPoint.coordinate;
        [KSLocationManager placemarkForCoordinate:coordinate completion:^(CLPlacemark *placemark) {
            controller.placemark = placemark;
        }];
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

        UISegmentedControl *control = (UISegmentedControl *)sender;
        controller.showsDatePicker = (control.selectedSegmentIndex > 0);
    }
}

- (void)updateAddressField:(UITextField *)addressField annotation:(MKPointAnnotation *)annotation {

    [KSLocationManager placemarkForCoordinate:annotation.coordinate completion:^(CLPlacemark *placemark) {
        NSString *address = placemark ? placemark.address : KSStringFromCoordinate(annotation.coordinate);
        addressField.text = address;
        annotation.subtitle = address;
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

#pragma mark -
#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    mapView.showsUserLocation = NO;
//    mapView.userTrackingMode = MKUserTrackingModeNone;

    if (!self.pickupPoint) {
        self.pickupPoint = [self annotationWithCoordinate:userLocation.location.coordinate title:KSPickupAnnotationTitle];
        [self updatePlacemarkForAnnotation:self.pickupPoint];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString * const pickupPinViewId = @"KSPickupPinView";
    static NSString * const dropOffPinViewId = @"KSDropoffPinView";
    
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    NSString *pinViewReuseIdentifier = (annotation == self.pickupPoint) ? pickupPinViewId : dropOffPinViewId;
    MKPinAnnotationColor pinColor = (annotation == self.pickupPoint) ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
    MKPinAnnotationView *pin;
    pin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinViewReuseIdentifier];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: pinViewReuseIdentifier];
        pin.canShowCallout = YES;
        pin.animatesDrop = YES;
        pin.draggable = YES;
    }

    pin.annotation = annotation;
    pin.pinColor = pinColor;

    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
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

    __block KSPointAnnotation *annotation;
    __block UITextField *addressField;
    __block MKMapView *mapView = self.mapView;

    if (!self.pickupPoint) {
        annotation = self.pickupPoint = [self annotationWithCoordinate:touchMapCoordinate title:KSPickupAnnotationTitle];
        addressField = self.txtPickupAddress;
        self.txtDropoffAddress.placeholder = KSDropoffTextPlaceholder;
    }
    else {
        if (!self.dropoffPoint) {
            self.dropoffPoint = [self annotationWithCoordinate:touchMapCoordinate title:KSDropoffAnnotationTitle];
        }
        else {
            [self.dropoffPoint setCoordinate:touchMapCoordinate];
        }
        annotation = self.dropoffPoint;
        addressField = self.txtDropoffAddress;
    }

    annotation.isInvalid = NO;

    [self updateAddressField:addressField annotation:annotation];

    [mapView selectAnnotation:annotation animated:YES];
}

- (IBAction)onClickPickupAddress:(id)sender {
    if (self.pickupPoint && !self.pickupPoint.isInvalid) {
        [self.mapView setCenterCoordinate:self.pickupPoint.coordinate animated:YES];
    }
}

- (IBAction)onClickDropoffAddress:(id)sender {
    if (self.pickupPoint && !self.dropoffPoint.isInvalid) {
        [self.mapView setCenterCoordinate:self.dropoffPoint.coordinate animated:YES];
    }
}

@end
