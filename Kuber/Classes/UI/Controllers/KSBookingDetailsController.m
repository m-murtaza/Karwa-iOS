//
//  KSBookingDetailsController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingDetailsController.h"
#import "KSTrip.h"

@interface KSBookingItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *details;

+ (instancetype)itemWithTitle:(NSString *)title details:(NSString *)details;

@end

@implementation KSBookingItem

+ (instancetype)itemWithTitle:(NSString *)title details:(NSString *)details {
    KSBookingItem *item = [[KSBookingItem alloc] init];
    item.title = title;
    item.details = details;
    return item;
}

@end

@interface KSBookingDetailsController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *bookingDetails;

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
    KSBookingItem *item;
    NSMutableArray *bookingDetails = [NSMutableArray array];
    if (trip.pickupLandmark.length) {
        item = [KSBookingItem itemWithTitle:@"Pickup From" details:trip.pickupLandmark];
        [bookingDetails addObject:item];
    }

    if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]) {

        NSString *location = KSStringFromLatLng(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue);
        item = [KSBookingItem itemWithTitle:@"Pickup Location" details:location];
        [bookingDetails addObject:item];
    }

    if (trip.pickupTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *date = [dateFormatter stringFromDate:trip.pickupTime];
        item = [KSBookingItem itemWithTitle:@"Booking Date" details: date];
    }

    if (trip.dropoffLandmark.length) {
        item = [KSBookingItem itemWithTitle:@"Destination" details:trip.dropoffLandmark];
        [bookingDetails addObject:item];
    }

    if ([self isValidLat:trip.dropOffLat lon:trip.dropOffLon]) {
        NSString *location = KSStringFromLatLng(trip.dropOffLat.doubleValue, trip.dropOffLon.doubleValue);
        item = [KSBookingItem itemWithTitle:@"Dropoff Location" details:location];
        [bookingDetails addObject:item];
    }
    
    self.bookingDetails = [NSArray arrayWithArray:bookingDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookingDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KSBookingDetailsCell" forIndexPath:indexPath];
    
    KSBookingItem *item = [self.bookingDetails objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.details;

    return cell;
}


@end
