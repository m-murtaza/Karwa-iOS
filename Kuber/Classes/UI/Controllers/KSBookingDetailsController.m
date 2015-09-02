//
//  KSBookingDetailsController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingDetailsController.h"
#import "KSTrip.h"


@interface KSBookingDetailsController ()

@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;

@property (weak, nonatomic) IBOutlet UILabel *lblDropoffAddress;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupTime;

@property (weak, nonatomic) IBOutlet UILabel *lblAcknowlegement;

@property (weak, nonatomic) IBOutlet UIButton *btnCancelBooking;

@property (weak, nonatomic) IBOutlet UILabel *lblDropoffTime;

@property (weak, nonatomic) IBOutlet UIView *dropoffContainer;


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

    if (trip.pickupLandmark.length) {
        
        self.lblPickupAddress.text = trip.pickupLandmark;
    }
    else  if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]){

        self.lblPickupAddress.text = KSStringFromCoordinate(CLLocationCoordinate2DMake(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue));
    }

    if (trip.dropoffLandmark.length) {
        
        self.lblDropoffAddress.text = trip.dropoffLandmark;
    }

    if ([trip.pickupTime isValidDate]) {
        self.lblPickupTime.text = [trip.pickupTime dateTimeString];
    }
    else {
        self.lblPickupTime.text = @"...";
    }

    if ([trip.dropOffTime isValidDate]) {
        
        self.lblDropoffTime.text = [trip.dropOffTime dateTimeString];
    }
    else {
        self.lblDropoffTime.text = @"...";
    }

    switch (trip.status.integerValue) {
        case KSTripStatusOpen:
        case KSTripStatusInProcess:
            if (self.showsAcknowledgement) {
                [self.btnCancelBooking removeFromSuperview];
                [self.btnCancelBooking setHidden:YES];
            }
            else {
                [self.lblAcknowlegement removeFromSuperview];
                [self.lblAcknowlegement setHidden:YES];
                NSTimeInterval pickupTimePast = -[trip.pickupTime timeIntervalSinceNow];
                NSTimeInterval CANCEL_TIMEOUT = 300.0;
                if ([trip.bookingType isEqualToString:KSBookingTypeCurrent]) {
                    CANCEL_TIMEOUT = -25.0 * 60.0;
                }
                if (pickupTimePast > CANCEL_TIMEOUT) {
                    [self.btnCancelBooking removeFromSuperview];
                    [self.btnCancelBooking setHidden:YES];
                }
                else {
                    [self.btnCancelBooking performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:CANCEL_TIMEOUT - pickupTimePast];
                }
            }
            break;

        default:
            [self.lblAcknowlegement removeFromSuperview];
            [self.lblAcknowlegement setHidden:YES];
            [self.btnCancelBooking removeFromSuperview];
            [self.btnCancelBooking setHidden:YES];

            break;
    }

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Booking Details"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnCancelTapped:(id)sender{
    
    [self cancelBooking];
}



#pragma mark - Private Functions 


-(void) cancelBooking
{
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [KSDAL cancelTrip:self.tripInfo completion:^(KSAPIStatus status, id response) {
       
        [hud hide:YES];
        if (KSAPIStatusSuccess == status) {
        
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"%s,cancel booking unSuccess \n Response is %@",__func__,response);
            KSStringFromAPIStatus(status);
            
            [KSAlert show:KSStringFromAPIStatus(status)
                    title:@"Error"
                 btnTitle:@"OK"];
            
        }
        
    }];
}
@end
