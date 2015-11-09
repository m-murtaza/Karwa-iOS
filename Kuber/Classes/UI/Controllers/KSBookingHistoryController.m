//
//  KSBookingHistoryController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingHistoryController.h"

#import "KSBookingHistoryCell.h"
#import "KSTripRatingController.h"
#import "KSBookingDetailsController.h"

@interface KSBookingHistoryController ()

@property (nonatomic, strong) NSArray *trips;
@property (nonatomic, strong) NSMutableDictionary *tripsData;
@property (nonatomic, strong) NSMutableArray *datesHeader;

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
    
    //Todo Need to remove repitative code
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if (_tripStatus == KSTripStatusPending) {
        self.navigationItem.title = @"Bookings";
        
    [KSDAL syncBookingHistoryWithCompletion:^(KSAPIStatus status, id response) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
                
                [me buildTripsHistory:[KSDAL fetchBookingHistoryFromDB]];
                
            }
            else
            {
                [KSAlert show:KSStringFromAPIStatus(status)];
            }
        }];
    }
    else if(_tripStatus == KSTripStatusCompletedNotRated){
        
        self.navigationItem.title = @"Rate your Trips";
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
}

#pragma mark -

- (void)buildTripsHistory:(NSArray*)data {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:NO];
    self.trips = [data sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    NSLog(@"%@",self.trips);
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Priveate Methods
-(void) createSectionHeader
{
    NSMutableArray * dates = [[NSMutableArray alloc] init];
    //self.datesHeader = [[NSMutableArray alloc] init];
    for (KSTrip *trip in self.trips) {
        
        NSDate *d = [NSDate dateAtBeginningOfDayForDate:trip.pickupTime];
        [dates addObject:d];
    }
    
    //This is unsorted array of date headers
    NSSet *uniqueStates = [NSSet setWithArray:dates];
    DLog(@"%@",uniqueStates);
    
    //Sorting the dates
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self"
                                                               ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    self.datesHeader = (NSMutableArray*)[uniqueStates.allObjects sortedArrayUsingDescriptors:descriptors];

}
-(void) createSectionData
{
    
    self.tripsData = [[NSMutableDictionary alloc] init];
    for (NSDate *date in self.datesHeader) {
       
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            KSTrip *trip = (KSTrip*)evaluatedObject;
            NSDate *d = [NSDate dateAtBeginningOfDayForDate:trip.pickupTime];
            return [d isEqualToDate:date];
        }];
        
        NSArray *secData = [self.trips filteredArrayUsingPredicate:predicate];
        [self.tripsData setObject:secData forKey:[NSDate bookingHistoryDateToString:date]];
    }
                                   
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
