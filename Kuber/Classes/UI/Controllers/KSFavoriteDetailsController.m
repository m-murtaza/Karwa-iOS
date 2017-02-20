//
//  KSFavoriteDetailsController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSFavoriteDetailsController.h"

#import <MapKit/MapKit.h>

#import "KSBookmark.h"
#import "KSLocationManager.h"
#import "KSPointAnnotation.h"
#import "KSAlert.h"
#import "KSGeoLocation.h"

#define LATITUDE_DELTA          0.112872
#define LONGITUDE_DELTA         0.109863

@interface KSFavoriteDetailsController ()<MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) KSPointAnnotation *annotation;

@property (nonatomic, weak) IBOutlet UITextField *txtName;
@property (nonatomic, weak) IBOutlet UILabel *lblAddress;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;


- (IBAction)onClickSave:(id)sender;

@end

@implementation KSFavoriteDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.lblAddress.text = self.landmark? self.landmark:@"Current Locaiton";
    if (self.bookmark) {
        self.txtName.text = self.bookmark.name;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.bookmark.latitude.doubleValue, self.bookmark.longitude.doubleValue);
        
        if (self.landmark.length) {
            
            [self addAnnotationWithCoordinate:coordinate];
        }
        else {
         
            [self updateAnnotationWithCoordinate:coordinate];
        }
    }
    else if (self.gLocation){
        
       CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.gLocation.latitude.doubleValue, self.gLocation.longitude.doubleValue);
        [self updateAnnotationWithCoordinate:coordinate];
        self.title = @"New Place";
    }
    else if (self.trip){
        CLLocationCoordinate2D coordinate;
        if (!self.trip.pickupLandmark && self.trip.dropoffLandmark) {
            coordinate = CLLocationCoordinate2DMake(self.trip.dropOffLat.doubleValue, self.trip.dropOffLon.doubleValue);
        }
        else{
            coordinate = CLLocationCoordinate2DMake(self.trip.pickupLat.doubleValue, self.trip.pickupLon.doubleValue);
            
        }
        [self updateAnnotationWithCoordinate:coordinate];
        self.title = @"New Place";
        
    }
    
    else {
        self.title = @"New Place";
        [KSLocationManager start];
        self.txtName.text = nil;
    }

    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressMapView:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];

    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    

    self.txtName.delegate = self;
    self.txtName.rightViewMode = UITextFieldViewModeAlways;
    
    
    UIColor *color = [UIColor colorWithRed:119.0/256.0 green:119.0/256.0 blue:119.0/256.0 alpha:1.0];
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter favorite name" attributes:@{NSForegroundColorAttributeName: color}];
    [self.txtName setTintColor:[UIColor blackColor]];
    //self.txtName.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];
    

}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Favorite Details"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeName:) name:UITextFieldTextDidChangeNotification object:self.txtName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    CLLocationCoordinate2D coordinate;
    if (self.bookmark) {
        //For Edit case
        coordinate = CLLocationCoordinate2DMake(self.bookmark.latitude.doubleValue, self.bookmark.longitude.doubleValue);
    }
    else if(self.gLocation){
    
        coordinate = CLLocationCoordinate2DMake(self.gLocation.latitude.doubleValue, self.gLocation.longitude.doubleValue);
    }
    else{
        __block KSFavoriteDetailsController *me = self;
        CLLocation *location = [KSLocationManager location];
        coordinate = location.coordinate;
        [KSLocationManager stop];
        
        [KSLocationManager placemarkForCoordinate:coordinate completion:^(KSGeoLocation *placemark) {
            if (placemark) {
                NSString *address = placemark.address;
                me.lblAddress.text = address;
            }
        }];
    }
    MKCoordinateRegion region = [self createRegionForLocation:coordinate];
    [self.mapView setRegion:region animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method

-(MKCoordinateRegion) createRegionForLocation:(CLLocationCoordinate2D) coordinate
{
    
    MKCoordinateRegion region;
    region.center.latitude = coordinate.latitude;
    region.center.longitude = coordinate.longitude;
    region.span.latitudeDelta = LATITUDE_DELTA;
    region.span.longitudeDelta = LONGITUDE_DELTA;
    
    return region;
}

#pragma mark -

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!self.annotation) {
        self.annotation = [[KSPointAnnotation alloc] init];
        self.annotation.title = self.txtName.text;
        self.annotation.subtitle = self.lblAddress.text;
        [self.mapView addAnnotation:self.annotation];
    }
    self.annotation.coordinate = coordinate;
    [self.mapView selectAnnotation:self.annotation animated:YES];
}

- (void)updateAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {

    __block KSFavoriteDetailsController *me = self;

    [self addAnnotationWithCoordinate:coordinate];

    [KSLocationManager placemarkForCoordinate:coordinate completion:^(KSGeoLocation *placemark) {
        if (placemark) {
            NSString *address = placemark.address;
            me.lblAddress.text = address;

            if (!me.txtName.text.length) {
                //me.txtName.text = placemark.address;
                me.annotation.title = placemark.address;
                me.annotation.subtitle = @"";
            }
            else {
                me.annotation.title = me.txtName.text;
                me.annotation.subtitle = placemark.area;
            }

            [me.mapView selectAnnotation:me.annotation animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    mapView.showsUserLocation = NO;
    mapView.userTrackingMode = MKUserTrackingModeNone;

    CLLocation *location = userLocation.location;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 4.0 * 1609.344, 4.0 * 1609.344);
    [_mapView setRegion:viewRegion animated:YES];
    
    if (!self.annotation) {
        [self updateAnnotationWithCoordinate:location.coordinate];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    NSString * const pinViewReuseIdentifier = @"KSBoomarkPinAnnotation";
    MKPinAnnotationColor pinColor = MKPinAnnotationColorGreen;
    MKPinAnnotationView *pin;
    pin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinViewReuseIdentifier];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: pinViewReuseIdentifier];
        pin.canShowCallout = YES;
        pin.animatesDrop = YES;
        pin.draggable = YES;
        pin.enabled = YES;
        pin.pinColor = pinColor;
    } else {
        pin.annotation = annotation;
    }

    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

    if (newState == MKAnnotationViewDragStateEnding) {
        if (self.annotation) {
            [self updateAnnotationWithCoordinate:self.annotation.coordinate];
        }
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return YES;
}


- (void)onChangeName:(NSNotification *)notification {

    if (self.annotation) {
        self.annotation.title = self.txtName.text;
        self.annotation.subtitle = self.lblAddress.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.txtName == textField) {

        [textField resignFirstResponder];
    }
    return YES;
}


#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, -200)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}


#pragma mark -
#pragma mark - Event handlers

- (IBAction)onClickSave:(id)sender {
    if (!self.txtName.text.length || !self.annotation) {
        [KSAlert show:@"Please add place name and select a location from map"];
        return;
    }
    if (self.bookmark != nil && self.txtName.text == self.bookmark.name &&
        self.bookmark.latitude.doubleValue == self.annotation.coordinate.latitude &&
        self.bookmark.longitude.doubleValue == self.annotation.coordinate.longitude) {
        [KSAlert show:@"No changes to save"];
        return;
    }
    
    __block UINavigationController *navController = self.navigationController;
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    void (^completionHandler)(KSAPIStatus, id) = ^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (KSAPIStatusSuccess == status) {
//            KSNotificationForNewBookmark
            [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationForNewBookmark object:nil];
            [navController popViewControllerAnimated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    };
    if (self.bookmark) {
        [KSDAL updateBookmark:self.bookmark withName:self.txtName.text coordinate:self.annotation.coordinate sortOrder:self.bookmark.sortOrder  completion:completionHandler];
    }
    else if (self.gLocation)
    {
        [KSDAL addBookMarkForGeoLocation:self.gLocation
                                withName:self.txtName.text
                              completion:completionHandler];
    }
    else if (self.trip){
        [KSDAL addBookMarkForTripData:self.trip
                             withName:self.txtName.text
                           completion:completionHandler];
    }
    else {
        NSString *address = self.lblAddress.text.length ? self.lblAddress.text : @"";
        [KSDAL addBookmarkWithName:self.txtName.text coordinate:self.annotation.coordinate address:address completion:completionHandler];
    }
}

- (void)onLongPressMapView:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    [self updateAnnotationWithCoordinate:touchMapCoordinate];
}


@end
