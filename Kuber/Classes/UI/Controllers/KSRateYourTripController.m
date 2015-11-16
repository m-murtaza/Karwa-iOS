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

-(void) fetchBookingDataFromServer
{
    __block KSBookingHistoryController *me = self;
    
    //Todo Need to remove repitative code
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.navigationItem.title = @"Rate your Trip";
        [KSDAL syncUnRatedBookingsWithCompletion:^(KSAPIStatus status, NSArray *trips) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
                [me buildTripsHistory:trips];
            }
            else{
                
                [KSAlert show:KSStringFromAPIStatus(status)];
            }
        }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KSTrip *trip = self.trips[indexPath.row];
    if (trip.status.integerValue == KSTripStatusComplete && !trip.rating) {
        KSTripRatingController *ratingController = [UIStoryboard tripRatingController];
        ratingController.trip = trip;
        [self.navigationController pushViewController:ratingController animated:YES];
    }
        
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}


@end
