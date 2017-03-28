//
//  KSBookingHistoryController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

@interface KSBookingHistoryController : KSViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) NSUInteger tripStatus;
@property (nonatomic, strong) NSArray *trips;
@property (nonatomic, strong) NSArray *taxiTrips;
@property (nonatomic, strong) NSArray *limoTrips;

@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) IBOutlet UISegmentedControl *segmentVehicleType;

- (IBAction)onSegmentVehicleTypeChange:(id)sender;

- (void)buildTripsHistory:(NSArray*)data;
@end
