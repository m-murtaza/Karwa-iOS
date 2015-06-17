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

@interface KSBookingHistoryController ()

@property (nonatomic, strong) NSArray *trips;

@end

@implementation KSBookingHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __block KSBookingHistoryController *me = self;

    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, NSArray *trips) {
        if (KSAPIStatusSuccess == status) {
            [me buildTripsHistory];
        }
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
#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![sender isKindOfClass:UITableViewCell.class]) {
        return NO;
    }
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KSTrip *trip = self.trips[indexPath.row];
    // Should go to rating view only if the trip is not rated yet
    return !trip.rating;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:UITableViewCell.class] && [segue.destinationViewController isKindOfClass:[KSTripRatingController class]]) {
        KSTripRatingController *controller = (KSTripRatingController *)segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        controller.trip = self.trips[indexPath.row];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    KSBookingHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KSBookingHistoryCell" forIndexPath:indexPath];

    KSTrip *trip = self.trips[indexPath.row];
    if (trip.rating) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    [cell updateCellData:trip];

    return cell;
}

@end
