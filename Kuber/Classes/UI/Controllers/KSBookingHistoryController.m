//
//  KSBookingHistoryController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingHistoryController.h"

#import "KSBookingHistoryCell.h"

#import "KSBookingDetailsController.h"

@interface KSBookingHistoryController ()


//@property (nonatomic, strong) NSMutableDictionary *tripsData;
//@property (nonatomic, strong) NSMutableArray *datesHeader;

@end

@implementation KSBookingHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KSGoogleAnalytics trackPage:@"Booking History"];
    
    [self fetchBookingDataFromServer];
}


#pragma mark - Server DataFetching 

-(void) fetchBookingDataFromServer
{
    __block KSBookingHistoryController *me = self;
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.navigationItem.title = @"Bookings";
        
    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, id response) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
            
                me.taxiTrips = [NSArray arrayWithArray:[KSDAL fetchTaxiBookingDB]];
                me.limoTrips = [NSArray arrayWithArray:[KSDAL fetchLimoBookingDB]];
                me.trips = [NSArray arrayWithArray:me.taxiTrips];
                [me.tableView reloadData];
            }
            else
            {
                [KSAlert show:KSStringFromAPIStatus(status)];
            }
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Vehicle Type Selection
- (IBAction)onSegmentVehicleTypeChange:(id)sender
{
    if(_segmentVehicleType.selectedSegmentIndex == 0)
        self.trips = [NSArray arrayWithArray:self.taxiTrips];
    else
        self.trips = [NSArray arrayWithArray:self.limoTrips];
    [self.tableView reloadData];
}

#pragma mark - Table View Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

//- (NSInteger)numberOfRowsInSection:(NSInteger)section {
//    return self.taxiTrips.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KSTrip *trip = self.trips[indexPath.row];
    //trip.status = [NSNumber numberWithInteger:KSTripStatusTaxiAssigned];
    
    KSBookingDetailsController *detailsController = [UIStoryboard bookingDetailsController];

    detailsController.tripInfo = trip;
    detailsController.showsAcknowledgement = NO;
    detailsController.navigationItem.leftBarButtonItem = nil;
    [self.navigationController pushViewController:detailsController animated:YES];
//    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                          action:@"didSelectedRowForBookingDetails"
                                                           label:[NSString stringWithFormat:@"jobId: %@ | Status = %@",trip.jobId,trip.status]
                                                           value:nil] build]];
}

@end
