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

@property (nonatomic, strong) UIView *overlayView;

@end

@implementation KSBookingHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    [self addSegmentControl];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KSGoogleAnalytics trackPage:@"Booking History"];
    
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
    _segmentVehicleType = [[NYSegmentedControl alloc] initWithItems:@[@"Taxi", @"Limo"]];
    
    _segmentVehicleType.titleTextColor = [UIColor colorWithRed:0.082f green:0.478f blue:0.537f alpha:1.0f];
    _segmentVehicleType.selectedTitleTextColor = [UIColor whiteColor];
    _segmentVehicleType.selectedTitleFont = [UIFont fontWithName:KSMuseoSans500 size:30.0];
    _segmentVehicleType.titleFont = [UIFont fontWithName:KSMuseoSans500 size:20.0];
    _segmentVehicleType.segmentIndicatorBackgroundColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];
    _segmentVehicleType.backgroundColor = [UIColor whiteColor];
    _segmentVehicleType.borderWidth = 0.0f;
    _segmentVehicleType.segmentIndicatorBorderWidth = 0.0f;
    _segmentVehicleType.segmentIndicatorInset = 2.0f;
    _segmentVehicleType.segmentIndicatorBorderColor = self.view.backgroundColor;
    [_segmentVehicleType setFrame:CGRectMake(self.view.frame.size.width / 2 -150, 13, 300, 40)];
    _segmentVehicleType.cornerRadius = CGRectGetHeight(_segmentVehicleType.frame) / 2.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    _segmentVehicleType.usesSpringAnimations = YES;
#endif
    
    [_segmentVehicleType addTarget:self action:@selector(onSegmentVehicleTypeChange) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_segmentVehicleType];
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
                if(_segmentVehicleType.selectedSegmentIndex == 0)
                    me.trips = [NSArray arrayWithArray:self.taxiTrips];
                else
                    me.trips = [NSArray arrayWithArray:self.limoTrips];

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
    NSInteger numberOfRows = self.trips.count;
    if (!numberOfRows) {
        [self showNoDataLabel];
    }
    else {
        [self hideNoDataLabel];
    }
    return numberOfRows;
    
    
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


#pragma mark - Overlay view 

const NSInteger KSViewOverlayTagForLoadingView = 10;
const NSInteger KSViewOverlayTagForNoDataLabel = 10;


- (UILabel *)noDataLabel {
    return (UILabel *)[self.overlayView viewWithTag:KSViewOverlayTagForNoDataLabel];
}

- (UIView *)overlayView {
    if (!_overlayView) {
        CGRect frameRect = self.tableView.frame;
        CGFloat y = 0;
        if (self.navigationController) {
            y = self.navigationController.navigationBar.frame.size.height;
        }
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.0, frameRect.size.width, frameRect.size.height - y)];
        _overlayView.backgroundColor = [UIColor clearColor];
        
        frameRect = _overlayView.frame;
        
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65.0, frameRect.size.width, frameRect.size.height)];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.text = KSTableViewDefaultErrorMessage;
        noDataLabel.textColor = [UIColor darkTextColor];
        noDataLabel.backgroundColor = self.tableView.backgroundColor;
        noDataLabel.tag = KSViewOverlayTagForNoDataLabel;
        
        [_overlayView addSubview:noDataLabel];
    }
    return _overlayView;
}

- (void)showNoDataLabel {
    
    [self.view addSubview:self.overlayView];
    //[self.tableView setScrollEnabled:NO];
    //[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0)];
}

- (void)hideNoDataLabel {
    
    [self.overlayView removeFromSuperview];
    //[self.tableView setScrollEnabled:YES];
}


@end
