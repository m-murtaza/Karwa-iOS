//
//  KSRateYourTripController.m
//  Kuber
//
//  Created by Asif Kamboh on 11/9/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSRateYourTripController.h"
#import "KSTripRatingController.h"

@implementation KSRateYourTripController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KSGoogleAnalytics trackPage:@"Rate your trip"];
}

-(void) fetchBookingDataFromServer
{
    __block KSBookingHistoryController *me = self;
    
    //Todo Need to remove repitative code
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.navigationItem.title = @"Rate your Trip";
        [KSDAL syncUnRatedBookingsWithCompletion:^(KSAPIStatus status, NSArray *trips) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
                //[me buildTripsHistory:trips];
                
                me.taxiTrips = [NSArray arrayWithArray:[KSDAL TaxiTrips:trips]];
                me.limoTrips = [NSArray arrayWithArray:[KSDAL LimoTrips:trips]];
                if(me.segmentVehicleType.selectedSegmentIndex == 0)
                    me.trips = [NSArray arrayWithArray:self.taxiTrips];
                else
                    me.trips = [NSArray arrayWithArray:self.limoTrips];
                
                [me.tableView reloadData];
            }
            else{
                
                [self APICallFailAction:status];
            }
        }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KSTrip *trip = self.trips[indexPath.row];
    if (trip.status.integerValue == KSTripStatusComplete && !trip.rating) {
        KSTripRatingController *ratingController = [UIStoryboard tripRatingController];
        ratingController.trip = trip;
        ratingController.displaySource = kRatingList;
        [self.navigationController pushViewController:ratingController animated:YES];
    }
        
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}


@end
