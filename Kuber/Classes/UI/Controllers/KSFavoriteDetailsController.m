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

    self.lblAddress.text = self.landmark;
    if (self.bookmark) {
        self.txtName.text = self.bookmark.name;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.bookmark.latitude.doubleValue, self.bookmark.longitude.doubleValue);
        if (self.landmark.length) {
            [self addAnnotationWithCoordinate:coordinate];
        } else {
            [self updateAnnotationWithCoordinate:coordinate];
        }
    }
    else {
        self.title = @"New Place";
    }

    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressMapView:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];

    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeName:) name:UITextFieldTextDidChangeNotification object:self.txtName];

}

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

    [KSLocationManager placemarkForCoordinate:coordinate completion:^(CLPlacemark *placemark) {
        if (placemark) {
            NSString *address = placemark.address;
            me.lblAddress.text = address;
            if (me.txtName.text.length) {
                me.annotation.subtitle = address;
            } else {
                me.annotation.title = address;
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

    if (!self.annotation) {
        [self updateAnnotationWithCoordinate:userLocation.location.coordinate];
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


- (void)onChangeName:(NSNotification *)notification {

    if (self.annotation) {
        self.annotation.title = self.txtName.text;
        self.annotation.subtitle = self.lblAddress.text;
    }
}

#pragma mark -
#pragma mark - Event handlers

- (IBAction)onClickSave:(id)sender {
#warning TODO: Add code validating the bookmark
#warning TODO: Add code for saving a bookmark
}

- (void)onLongPressMapView:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    [self updateAnnotationWithCoordinate:touchMapCoordinate];
}


@end
