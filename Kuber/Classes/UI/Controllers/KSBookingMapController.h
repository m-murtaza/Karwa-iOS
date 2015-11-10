//
//  KSBookingMapController.h
//  Kuber
//
//  Created by Asif Kamboh on 9/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KSViewController.h"


@interface KSBookingMapController : KSViewController <MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) KSTrip *repeatTrip;
@end
