//
//  KSBookingConfirmationController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/3/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingConfirmationController.h"
#import "KSAddress.h"
#import "KSDatePicker.h"

#import "KSBookingDetailsController.h"
#import "KSAddressPickerController.h"


@interface KSBookingConfirmationController ()<UITableViewDelegate, UITableViewDataSource, KSDatePickerDelegate, KSAddressPickerDelegate>
{
    NSArray *_savedBookmarks;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgPickupTimeArrow;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupLandmark;

@property (weak, nonatomic) IBOutlet UIButton *btnDropoffLandmark;

@property (weak, nonatomic) IBOutlet UITextField *txtPickupTime;

@property (weak, nonatomic) IBOutlet UIView *recentView;

- (IBAction)onClickConfirmBooking:(id)sender;

- (IBAction)onClickDestinationLandmark:(id)sender;

@end

NSString * const KSDefaultPickupText = @"You location";

@implementation KSBookingConfirmationController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.lblPickupLandmark.text = self.pickupLandmark;

    if (self.dropoffAddress.landmark.length) {
        
        [self.btnDropoffLandmark setTitle:self.dropoffAddress.landmark forState:UIControlStateNormal];
    }

    NSDate* date = [NSDate date];

    if (self.showsDatePicker) {

        // Min date should be 30mins after current time
        NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:30 * 60];
        // Max date should be 15 day ahead only
        NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:30 * 24 * 60 * 60];

        date = minDate;
        
        KSDatePicker *picker = [[KSDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        picker.minimumDate = minDate;
        picker.maximumDate = maxDate;

        picker.delegate = self;

        self.txtPickupTime.inputView = picker;

        [self.imgPickupTimeArrow setAlpha:1.0];
    }
    else {
        
        self.txtPickupTime.enabled = NO;

        [self.imgPickupTimeArrow setAlpha:0];
    }

    [self updatePickupTime:date];
    
    _savedBookmarks = [[[KSDAL loggedInUser] bookmarks] allObjects];
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

- (NSString *)pickupLandmark {
    
    return self.pickupAddress.landmark.length ? self.pickupAddress.landmark : KSDefaultPickupText;
}

- (NSString *)dropoffLandmark {

    return self.dropoffAddress.landmark;
}

- (CLLocationDegrees)pickupLat {

    return self.pickupAddress.coordinate.latitude;
}

- (CLLocationDegrees)pickupLon {

    return self.pickupAddress.coordinate.longitude;
}

- (void)updateDropoffLandmark {
    
    [self.btnDropoffLandmark setTitle:self.dropoffAddress.landmark forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Recent Locations Data source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _savedBookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"KSBookmarkCellId" forIndexPath:indexPath];

    KSBookmark *bookmark = [_savedBookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.name;
    if (bookmark.address.length) {
        cell.detailTextLabel.text = bookmark.address;
    }
    else {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(bookmark.latitude.doubleValue, bookmark.longitude.doubleValue);
        cell.detailTextLabel.text = KSStringFromCoordinate(coordinate);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KSBookmark *bookmark = [_savedBookmarks objectAtIndex:indexPath.row];

    NSString *landmark = bookmark.name;
    if (bookmark.address.length) {
        landmark = bookmark.address;
    }
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(bookmark.latitude.doubleValue, bookmark.longitude.doubleValue);
    KSAddress *address = [KSAddress addressWithLandmark:landmark coordinate:coordinate];

    self.dropoffAddress = address;
    [self updateDropoffLandmark];

}

#pragma mark -
#pragma mark - Address Picker Delegate

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location {
    
    self.dropoffAddress = [KSAddress addressWithLandmark:address location:location];
    [self updateDropoffLandmark];
}

#pragma mark -
#pragma mark - Date picker delegate

- (void)updatePickupTime:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yy, HH:mm"];

    self.txtPickupTime.text = [formatter stringFromDate:date];
}

- (void)datePicker:(KSDatePicker *)picker didPickDate:(NSDate *)date {
    
    [self.txtPickupTime resignFirstResponder];
    
    [self updatePickupTime:date];
}

#pragma mark -
#pragma mark - Button Click Handlers

- (IBAction)onClickPickupTime:(id)sender {
    
}

- (IBAction)onClickDestinationLandmark:(id)sender {
    
    KSAddressPickerController *controller = [UIStoryboard addressPickerController];
    controller.pickerId = @"x";
    controller.delegate = self;

    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onClickConfirmBooking:(id)sender {

    NSLog(@"%s", __func__);

    KSTrip *tripInfo = [KSDAL tripWithLandmark:self.pickupLandmark lat:self.pickupLat lon:self.pickupLon];
    tripInfo.dropoffLandmark = self.dropoffLandmark;

    if (self.showsDatePicker) {
        UIDatePicker *datePicker = (UIDatePicker *)self.txtPickupTime.inputView;
        tripInfo.pickupTime = datePicker.date;
    }

    if (self.dropoffAddress.location) {
        CLLocationCoordinate2D coordinate = self.dropoffAddress.location.coordinate;
        tripInfo.dropOffLat = [NSNumber numberWithDouble:coordinate.latitude];
        tripInfo.dropOffLon = [NSNumber numberWithDouble:coordinate.longitude];
    }

    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [KSDAL bookTrip:tripInfo completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            KSBookingDetailsController *controller = (KSBookingDetailsController *)[UIStoryboard bookingDetailsController];
            controller.tripInfo = tripInfo;
            controller.showsAcknowledgement = YES;
            if (!tripInfo.pickupTime) {
                tripInfo.pickupTime = [NSDate date];
            }
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }

    }];
}

@end
