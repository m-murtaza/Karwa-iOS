//
//  KSBookingDetailsController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingDetailsController.h"
#import "KSTrip.h"


@interface KSBookingDetailsController ()

@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;

@property (weak, nonatomic) IBOutlet UILabel *lblDropoffAddress;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupTime;

@end

@implementation KSBookingDetailsController

- (BOOL)isValidLat:(NSNumber *)lat lon:(NSNumber *)lon {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    return [CLLocation isValidCoordinate:coordinate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    KSTrip *trip = self.tripInfo;

    if (trip.pickupLandmark.length) {
        
        self.lblPickupAddress.text = trip.pickupLandmark;
    }
    else  if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]){

        self.lblPickupAddress.text = KSStringFromCoordinate(CLLocationCoordinate2DMake(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue));
    }

    if (trip.dropoffLandmark.length) {
        
        self.lblDropoffAddress.text = trip.dropoffLandmark;
    }

    if (trip.pickupTime ) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *minDate = [dateFormatter dateFromString:@"2010-01-01"];

        if ([minDate compare:trip.pickupTime] == NSOrderedAscending) {
            
            [dateFormatter setDateFormat:@"MMM dd, yy, HH:mm"];

            self.lblPickupTime.text = [dateFormatter stringFromDate:trip.pickupTime];
        }
    }
    else {
        self.lblPickupTime.text = @"...";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
