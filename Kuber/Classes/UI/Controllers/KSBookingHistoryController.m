//
//  KSBookingHistoryController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingHistoryController.h"

#import "KSTrip.h"
#import "KSUser.h"
#import "KSDAL.h"

#import "KSBookingHistoryCell.h"
#import "KSTripRatingController.h"
#import "KSBookingDetailsController.h"

@interface KSBookingHistoryController ()

@property (nonatomic, strong) NSArray *trips;

@end

@implementation KSBookingHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __block KSBookingHistoryController *me = self;

    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, NSArray *trips) {
        [me buildTripsHistory];
    }];

}

- (void)buildTripsHistory {

    KSUser *user = [KSDAL loggedInUser];
    self.trips = [user.trips.allObjects sortedArrayUsingComparator:^NSComparisonResult(KSTrip * obj1, KSTrip *obj2) {
        return [obj2.pickupTime compare:obj1.pickupTime];
    }];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self buildTripsHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Table View Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    KSBookingHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KSBookingHistoryCell" forIndexPath:indexPath];

    KSTrip *trip = self.trips[indexPath.row];
    if (trip.rating || trip.status.unsignedIntegerValue != KSTripStatusComplete) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    [cell updateCellData:trip];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KSTrip *trip = self.trips[indexPath.row];

    
    //Usman Temp Work
    
    if (trip.status.integerValue == KSTripStatusComplete && !trip.rating) {
        KSTripRatingController *ratingController = [UIStoryboard tripRatingController];
        ratingController.trip = trip;
        [self.navigationController pushViewController:ratingController animated:YES];
    }
    else {
        KSBookingDetailsController *detailsController = [UIStoryboard bookingDetailsController];
        detailsController.tripInfo = trip;
        detailsController.showsAcknowledgement = NO;
        detailsController.navigationItem.leftBarButtonItem = nil;
        [self.navigationController pushViewController:detailsController animated:YES];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

@end
