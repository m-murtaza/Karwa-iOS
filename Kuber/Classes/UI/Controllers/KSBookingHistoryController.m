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

#import "NYSegmentedControl.h"

@interface KSBookingHistoryController ()
{
    NYSegmentedControl *segmentVehicleType;
}

//@property (nonatomic, strong) NSMutableDictionary *tripsData;
//@property (nonatomic, strong) NSMutableArray *datesHeader;

@end

@implementation KSBookingHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KSGoogleAnalytics trackPage:@"Booking History"];
    
    [self addSegmentControl];
    
    [self fetchBookingDataFromServer];
}

#pragma mark - SegmentControl 

//This function is to add UI and have lot of hardcode values.
-(void) addSegmentControl
{
    //self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    //Background view
    UIView *segmentBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 CGRectGetWidth([UIScreen
                                                                                 mainScreen].bounds),
                                                                 65.0f)];
    segmentBg.backgroundColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];
    [self.view addSubview:segmentBg];
    
    //Segment Control
    segmentVehicleType = [[NYSegmentedControl alloc] initWithItems:@[@"Taxi", @"Limo"]];
    
    segmentVehicleType.titleTextColor = [UIColor colorWithRed:0.082f green:0.478f blue:0.537f alpha:1.0f];
    segmentVehicleType.selectedTitleTextColor = [UIColor whiteColor];
    segmentVehicleType.selectedTitleFont = [UIFont fontWithName:KSMuseoSans500 size:30.0];
    segmentVehicleType.titleFont = [UIFont fontWithName:KSMuseoSans500 size:20.0];
    segmentVehicleType.segmentIndicatorBackgroundColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];
    segmentVehicleType.backgroundColor = [UIColor whiteColor];
    segmentVehicleType.borderWidth = 0.0f;
    segmentVehicleType.segmentIndicatorBorderWidth = 0.0f;
    segmentVehicleType.segmentIndicatorInset = 2.0f;
    segmentVehicleType.segmentIndicatorBorderColor = self.view.backgroundColor;
    [segmentVehicleType setFrame:CGRectMake(self.view.frame.size.width / 2 -150, 13, 300, 40)];
    segmentVehicleType.cornerRadius = CGRectGetHeight(segmentVehicleType.frame) / 2.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    segmentVehicleType.usesSpringAnimations = YES;
#endif
    
    [segmentVehicleType addTarget:self action:@selector(onSegmentVehicleTypeChange) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:segmentVehicleType];
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
- (IBAction)onSegmentVehicleTypeChange
{
    if(segmentVehicleType.selectedSegmentIndex == 0)
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
