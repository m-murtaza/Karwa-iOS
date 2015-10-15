//
//  KSBookingDetailsController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingDetailsController.h"
#import "KSTrip.h"
#import "NSString+KSExtended.h"

//ViewControllers
#import "KSTripRatingController.h"
#import "KSTrackTaxiController.h"

@interface KSBookingDetailsController ()

@property (weak, nonatomic) IBOutlet KSLabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet KSLabel *lblDropoffAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAcknowlegement;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelBooking;
@property (weak, nonatomic) IBOutlet UILabel *lblDropoffTime;
@property (weak, nonatomic) IBOutlet UIView *dropoffContainer;
@property (weak, nonatomic) IBOutlet KSLabel *lblTitleTaxiInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet KSLabel *lblDriverNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet KSLabel *lblTaxiNumber;

@property (weak, nonatomic) IBOutlet UIView *viewTaxiInfo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPickupTimeBottom;

-(IBAction)btnCallDriveTapped:(id)sender;


@end

@implementation KSBookingDetailsController

- (BOOL)isValidLat:(NSNumber *)lat lon:(NSNumber *)lon {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    return [CLLocation isValidCoordinate:coordinate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    [self.lblPickupAddress setFontSize:13];
//    [self.lblDropoffAddress setFontSize:13];
//    [self.lblTitleTaxiInfo setFontSize:12];
//    [self.lblTaxiNumber setFontSize:12];
//    [self.lblDriverNumber setFontSize:12];
    
    [self.lblAcknowlegement setHidden:TRUE];
    
    [self loadViewData];
    if (self.isOpenedFromPushNotification ) {
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        self.revealButtonItem = barButton;
        [barButton setImage:[UIImage imageNamed:@"reveal-icon.png"]];
        self.navigationItem.leftBarButtonItem = barButton;
        [self setupRevealViewController];
        
        if ([self.tripInfo.status integerValue] == KSTripStatusTaxiNotFound) {
            [KSAlert show:@"Dear Customer, we are fully booked, Please try different pick up time"];
        }
        else if([self.tripInfo.status integerValue] == KSTripStatusComplete && self.tripInfo.rating == nil){
            
            [self performSegueWithIdentifier:@"segueBookingDetailsToRate" sender:self];
            /*KSTripRatingController *ratingController = [UIStoryboard tripRatingController];
            ratingController.trip = self.tripInfo;
            [self.navigationController pushViewController:ratingController animated:NO];*/
        
        }
    }
    
    [self setNavigationTitle];
    
    if(IS_IPHONE_5){
        self.constraintPickupTimeBottom.constant = 5.0;
    }
    
    [self showHideTrackATaxiButton];
}

- (void) setNavigationTitle
{
    if (self.tripInfo.jobId.length) {
        self.navigationItem.title = [NSString stringWithFormat:@"Order No. %@", self.tripInfo.jobId];
    }
}

-(void) loadViewData
{
    KSTrip *trip = self.tripInfo;
    
    //Set Pickup Address
    if (trip.pickupLandmark.length) {
        
        self.lblPickupAddress.text = trip.pickupLandmark;
    }
    else if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]){
        
        self.lblPickupAddress.text = KSStringFromCoordinate(CLLocationCoordinate2DMake(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue));
    }
    else {
        self.lblPickupAddress.text = @"";
    }
    
    //Set Drop Off Address
    if (trip.dropoffLandmark.length) {
        
        self.lblDropoffAddress.text = trip.dropoffLandmark;
    }
    else {
        self.lblDropoffAddress.text = @"";
    }
    
    //Set Top Pick Up date
    if ([trip.pickupTime isValidDate]) {
        self.lblPickupDate.text = [self getFormattedTitleDate:trip.pickupTime];
    }
    else {
        self.lblPickupDate.text = @"...";
    }
    
    //Set Pick Up Time
    if ([trip.pickupTime isValidDate]) {
        self.lblPickupTime.text = [self getTimeStringFromDate:trip.pickupTime];
    }
    else {
        self.lblPickupTime.text = @"...";
    }
    
    //Set Drop Off Up Time
    if ([trip.dropOffTime isValidDate]) {
        
        self.lblDropoffTime.text = [self getTimeStringFromDate:trip.dropOffTime];
    }
    else {
        self.lblDropoffTime.text = @"...";
    }
    
    /*if (trip.taxi == nil) {
        [self.lblTitleTaxiInfo setHidden:TRUE];
        [self.viewTaxiInfo setHidden:TRUE];
    }*/
    
    [self.lblAcknowlegement setHidden:TRUE];
    [self.btnCancelBooking setHidden:TRUE];
    [self setStatusForTrip:trip];
    
    [self setTaxiInfo:trip];
    
}

-(void) hideTaxiInfo:(KSTrip*)trip
{
    [self.lblTitleTaxiInfo setHidden:TRUE];
    [self.viewTaxiInfo setHidden:TRUE];
}

-(void) setTaxiInfo:(KSTrip*)trip
{
    if (trip.driver == nil) {
        
        [self hideTaxiInfo:trip];
    }
    else {
        [self.lblTitleTaxiInfo setHidden:FALSE];
        KSDriver *driver = trip.driver;
        self.lblDriverName.text = driver.name;
        self.lblDriverNumber.text = driver.phone ;

        KSTaxi *taxi = trip.taxi;
        self.lblTaxiNumber.text = [NSString stringWithFormat:@"Taxi #: %@",taxi.number]; 
        
        if (trip.estimatedTimeOfArival != nil) {
            
            NSString *eta = [NSString stringWithFormat:@"%@ Mins",trip.estimatedTimeOfArival];
            self.lblETA.text = eta;
        }
        
    }
}


-(void) setStatusForTrip:(KSTrip*)trip
{
    switch (trip.status.integerValue) {
        case KSTripStatusOpen:
        case KSTripStatusInProcess:
        case KSTripStatusPending:
        case 12:
        case 4:
            [self.btnCancelBooking setHidden:FALSE];
    }
    
    
    //We might need this code in future. 
    /*switch (trip.status.integerValue) {
        case KSTripStatusOpen:
        case KSTripStatusInProcess:
        case KSTripStatusPending:
        case 12:
        case 4:
            [self.lblAcknowlegement setHidden:YES];
            NSTimeInterval pickupTimePast = -[trip.pickupTime timeIntervalSinceNow];
            NSTimeInterval CANCEL_TIMEOUT = 300.0;
            if (![trip.bookingType isEqualToString:KSBookingTypeCurrent]) {
                CANCEL_TIMEOUT = -20.0 * 60.0;
                [self.lblAcknowlegement setHidden:FALSE];
                [self.lblAcknowlegement setText:@"This is text for Advance booking button disable"];
            }
            if (pickupTimePast > CANCEL_TIMEOUT) {
                [self.btnCancelBooking setEnabled:FALSE];
                [self.lblAcknowlegement setHidden:FALSE];
                [self.lblAcknowlegement setText:@"This is text for Current booking button disable"];

            }
            else {
                [self performSelector:@selector(disableCancelButton) withObject:nil afterDelay:CANCEL_TIMEOUT - pickupTimePast];
            }

            break;
            
        default:
            [self.lblAcknowlegement removeFromSuperview];
            [self.lblAcknowlegement setHidden:YES];
            [self.btnCancelBooking removeFromSuperview];
            [self.btnCancelBooking setHidden:YES];
            
            break;
    }*/
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

#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueBookingDetailsToRate"]){
        KSTripRatingController *ratingController = (KSTripRatingController*)segue.destinationViewController;
        ratingController.trip = self.tripInfo;
    }
    else if([segue.identifier isEqualToString:@"segueDetailsToTrack"])
    {
        KSTrackTaxiController *trackTaxi = (KSTrackTaxiController*) segue.destinationViewController;
        trackTaxi.taxiNo = self.tripInfo.taxi.number;
    }
}

#pragma mark - Event handler

-(IBAction)btnCallDriveTapped:(id)sender
{
    if (self.tripInfo.driver.phone != nil || ![self.tripInfo.driver.phone isEqualToString:@""]) {
        
        
        if ([self.tripInfo.driver.phone isPhoneNumber]) {
            
            NSString *phoneNumber = [@"tel://" stringByAppendingString:self.tripInfo.driver.phone];
            NSURL *phone = [NSURL URLWithString:phoneNumber];
            UIApplication *app = [UIApplication sharedApplication];
            if ([app canOpenURL:phone]) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            else{
                
                [KSAlert show:@"Your phone does not support calling" title:@"Error"];
            }
        }
        else {
        
            [KSAlert show:@"Invalid phone number" title:@"Error"];
        }
        
    }
}

-(IBAction)btnCancelTapped:(id)sender{
    
    [self cancelBooking];
}



#pragma mark - Private Functions 
-(void) showHideTrackATaxiButton
{
    if (self.tripInfo.taxi == nil) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


-(void) disableCancelButton
{
    [self.btnCancelBooking setEnabled:FALSE];
}

-(NSString*) getFormattedTitleDate:(NSDate*)date
{
    NSDateFormatter *formator = [[NSDateFormatter alloc] init];
    [formator setDateFormat:@"EEE d MMM"];
    NSString *str = [formator stringFromDate:date];
    return [str uppercaseString];
}

-(NSString*) getTimeStringFromDate:(NSDate*) date
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"H:mm";
    
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    return dateString;
}

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
