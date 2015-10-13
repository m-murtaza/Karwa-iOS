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

@interface KSTrackTaxiController () <MKMapViewDelegate>

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
    
    [self addAnotations];
}

-(void) addAnotations
{

}

@end
