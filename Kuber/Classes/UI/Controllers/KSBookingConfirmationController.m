//
//  KSBookingConfirmationController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/3/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingConfirmationController.h"

#import "KSDAL.h"
#import "KSTrip.h"
#import "MBProgressHUD.h"
#import "KSAlert.h"

#import "KSAddress.h"

#import "KSBookingDetailsController.h"

@interface KSBookingConfirmationController ()

@property (weak, nonatomic) IBOutlet UITextField *txtPickupLandmark;

@property (weak, nonatomic) IBOutlet UITextField *txtDropoffLandmark;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupDateCaption;
@property (weak, nonatomic) IBOutlet UIDatePicker *dpPickupDate;

- (IBAction)onClickConfirmBooking:(id)sender;

@end

@implementation KSBookingConfirmationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblPickupDateCaption.hidden = !self.showsDatePicker;
    self.dpPickupDate.hidden = !self.showsDatePicker;

    self.txtPickupLandmark.text = self.pickupAddress.landmark;
    self.txtDropoffLandmark.text = self.dropoffAddress.landmark;

    // Min date should be 30mins after current time
    NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:30 * 60];
    // Max date should be 15 day ahead only
    NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:30 * 24 * 60 * 60];
    self.dpPickupDate.minimumDate = minDate;
    self.dpPickupDate.maximumDate = maxDate;
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
    if (self.txtPickupLandmark.text.length) {
        return self.txtPickupLandmark.text;
    }
    return self.pickupAddress.landmark;
}

- (NSString *)dropoffLandmark {
    if (self.txtDropoffLandmark.text.length) {
        return self.txtDropoffLandmark.text;
    }
    return self.dropoffAddress.landmark;
}

- (CLLocationDegrees)pickupLat {
    return self.pickupAddress.coordinate.latitude;
}

- (CLLocationDegrees)pickupLon {
    return self.pickupAddress.coordinate.longitude;
}

- (IBAction)onClickConfirmBooking:(id)sender {
     NSLog(@"%s", __func__);

    KSTrip *tripInfo = [KSDAL tripWithLandmark:self.pickupLandmark lat:self.pickupLat lon:self.pickupLon];
    tripInfo.dropoffLandmark = self.dropoffLandmark;

    NSDate *pickupTime = [NSDate date];
    if (self.showsDatePicker) {
        pickupTime = self.dpPickupDate.date;
    }
    tripInfo.pickupTime = pickupTime;

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
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }

    }];
}

@end
