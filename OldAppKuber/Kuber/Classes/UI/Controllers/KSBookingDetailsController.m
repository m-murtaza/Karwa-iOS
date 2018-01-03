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
#import "KSConfirmationAlert.h"
#import "KSTrackTaxiController.h"
#import "SWRevealViewController.h"
#import "KSBookingMapController.h"
#import "AppUtils.h"

typedef enum {
    
    BtnStateCancel = 0,
    BtnStateBookAgain = 1
    
}
BtnState;

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
@property (weak, nonatomic) IBOutlet UIImageView *imgVehicleType;
@property (weak, nonatomic) IBOutlet UIImageView *imgNumberPlate;


@property (weak, nonatomic) IBOutlet UIView *viewTaxiInfo;
@property (weak, nonatomic) IBOutlet UIView *viewTrackMyTaxi;
@property (weak, nonatomic) IBOutlet UIButton *btnTrack;
@property (weak, nonatomic) IBOutlet UIImageView *imgTrackTaxiSepLine;

@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPickupTimeBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTaxiInfoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTaxiInfoBGImgBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVehicleNumber;


-(IBAction)btnCallDriveTapped:(id)sender;


@end

@implementation KSBookingDetailsController

- (BOOL)isValidLat:(NSNumber *)lat lon:(NSNumber *)lon {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    return [CLLocation isValidCoordinate:coordinate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.lblAcknowlegement setHidden:TRUE];
    
    [self loadViewData];
    if (self.isOpenedFromPushNotification ) {
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        self.revealButtonItem = barButton;
        [barButton setImage:[UIImage imageNamed:@"reveal-icon.png"]];
        self.navigationItem.leftBarButtonItem = barButton;
        
        if ([self.tripInfo.status integerValue] == KSTripStatusTaxiNotFound) {
            [KSAlert show:@"Dear Customer, we are fully booked, Please try different pick up time"];
        }
    }
    
    if(1 || [self.tripInfo.status integerValue] == KSTripStatusComplete && self.tripInfo.rating == nil){
        
        [self performSegueWithIdentifier:@"segueBookingDetailsToRate" sender:self];
        /*KSTripRatingController *ratingController = [UIStoryboard tripRatingController];
         ratingController.trip = self.tripInfo;
         [self.navigationController pushViewController:ratingController animated:NO];*/
    }
    [self setNavigationTitle];
    
    if(IS_IPHONE_5){
        self.constraintPickupTimeBottom.constant = 5.0;
        self.constraintTaxiInfoViewHeight.constant -= 40;
    }
    
    [self showHideTrackATaxiButton];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTrackingOption];
    
    [self setCancelBtnStatusForTrip:self.tripInfo];
    [self setTaxiInfo:self.tripInfo];
    
    [KSGoogleAnalytics trackPage:@"Booking Details"];
    
    [self updateStatusOfTaxi];
}

- (void) setNavigationTitle
{
    if (self.tripInfo.jobId.length) {
        self.navigationItem.title = [NSString stringWithFormat:@"Order No. %@", self.tripInfo.jobId];
    }
}

-(void) loadViewData
{
    [self.view layoutIfNeeded];                 //For some reason not able to change the font size if don't call this method.  Strange!
    KSTrip *trip = self.tripInfo;
    DLog(@"Booking Detail Trip data %@",trip);
    //Set Pickup Address
    if (trip.pickupLandmark.length) {
        
        self.lblPickupAddress.text = trip.pickupLandmark;//[NSString stringWithFormat:@"%@, %@",trip.pickupHint, trip.pickupLandmark];
    }
    else if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]){
        
        self.lblPickupAddress.text = KSStringFromCoordinate(CLLocationCoordinate2DMake(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue));
    }
    else {
        self.lblPickupAddress.text = @"";
    }
    
    //Set Drop Off Address
    if (trip.dropoffLandmark && trip.dropoffLandmark.length) {
        
        self.lblDropoffAddress.text = trip.dropoffLandmark;
    }
    else {
        self.lblDropoffAddress.text = @"No Destination Set";
        [self.lblDropoffAddress setFont: [UIFont fontWithName:KSMuseoSans300Italic size:17]];
    }
    
    //Set Top Pick Up date
    DLog(@"Detail screen Pickup time %@", trip.pickupTime);
    if ([trip.pickupTime isValidDate]) {
        DLog(@"Pickup date is valid ");
        self.lblPickupDate.text = [self getFormattedTitleDate:trip.pickupTime];
        DLog(@"Date is %@",self.lblPickupDate.text);
    }
    else {
        DLog(@"Date is not valid");
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
        self.lblDropoffTime.text = @"--:--";
    }
    
    /*if (trip.taxi == nil) {
        [self.lblTitleTaxiInfo setHidden:TRUE];
        [self.viewTaxiInfo setHidden:TRUE];
    }*/
    
    
    [self setCancelBtnStatusForTrip:trip];
    
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
        
        NSString *taxiNum = [NSString stringWithFormat:@"%@",taxi.number];
        taxiNum = [taxiNum substringFromIndex:3];
        self.lblTaxiNumber.text = taxiNum;
        
        
        switch((KSVehicleType)[trip.vehicleType integerValue])
        {
            case KSCityTaxi:
                [_imgVehicleType setImage:[UIImage imageNamed:@"Booking-details-taxitag"]];
                [_imgNumberPlate setImage:[UIImage imageNamed:@"Booking-details-numberplate"]];
                break;
            case KSStandardLimo:
                [_imgVehicleType setImage:[UIImage imageNamed:@"Booking-details-standardtag"]];
                [_imgNumberPlate setImage:[UIImage imageNamed:@"Booking-details-limonumberplate"]];
                [self.lblTaxiNumber setFont:[UIFont fontWithName:KSMuseoSans700 size:21]];
                _constraintVehicleNumber.constant += 5;
                break;
            case KSBusinessLimo:
                [_imgVehicleType setImage:[UIImage imageNamed:@"Booking-details-businesstag"]];
                [_imgNumberPlate setImage:[UIImage imageNamed:@"Booking-details-limonumberplate"]];
                [self.lblTaxiNumber setFont:[UIFont fontWithName:KSMuseoSans700 size:21]];
                _constraintVehicleNumber.constant += 5;
                break;
            case KSLuxuryLimo:
                [_imgVehicleType setImage:[UIImage imageNamed:@"Booking-details-luxurytag"]];
                [_imgNumberPlate setImage:[UIImage imageNamed:@"Booking-details-limonumberplate"]];
                [self.lblTaxiNumber setFont:[UIFont fontWithName:KSMuseoSans700 size:21]];
                _constraintVehicleNumber.constant += 5;
                break;
            default:
                [_imgVehicleType setImage:[UIImage imageNamed:@"Booking-details-taxitag"]];
                [_imgNumberPlate setImage:[UIImage imageNamed:@"Booking-details-numberplate"]];
        }
        
        
        if (trip.estimatedTimeOfArival != nil) {
            
            NSString *eta = [NSString stringWithFormat:@"ETA: %@ Mins",trip.estimatedTimeOfArival];
            self.lblETA.text = eta;
        }
        
        [self updateTrackingOption];
    }
}

-(void) updateTrackingOption
{
    if ([self.tripInfo.status integerValue] != KSTripStatusTaxiAssigned) {
        
        [self.viewTrackMyTaxi setHidden:TRUE];
        [self.imgTrackTaxiSepLine setHidden:TRUE];
        self.constraintTaxiInfoBGImgBottom.constant = 50;
    }
    else{
        [self.viewTrackMyTaxi setHidden:FALSE];
        [self.imgTrackTaxiSepLine setHidden:FALSE];
        self.constraintTaxiInfoBGImgBottom.constant = 0;
    }
//    [self.viewTrackMyTaxi setHidden:FALSE];
//    [self.imgTrackTaxiSepLine setHidden:FALSE];
//    self.constraintTaxiInfoBGImgBottom.constant = 0;
    
}

-(void) setCancelBtnStatusForTrip:(KSTrip*)trip
{
    
    [self.lblAcknowlegement setHidden:TRUE];
    //[self.btnCancelBooking setHidden:FALSE];
    switch (trip.status.integerValue) {
        case KSTripStatusOpen:
        case KSTripStatusInProcess:
        case KSTripStatusPending:
        case 12:
        case 4:
            //[self.btnCancelBooking setHidden:FALSE];
            [self.btnCancelBooking setTag:BtnStateCancel];
            [self.btnCancelBooking setTitle:@"Cancel Booking" forState:UIControlStateNormal];
            [self.btnCancelBooking setTitle:@"CANCEL BOOKING" forState:UIControlStateHighlighted];
            break;
        default:
            //[self.btnCancelBooking setHidden:FALSE];
            [self.btnCancelBooking setTag:BtnStateBookAgain];
            [self.btnCancelBooking setTitle:@"BOOK AGAIN" forState:UIControlStateNormal];
            [self.btnCancelBooking setTitle:@"BOOK AGAIN" forState:UIControlStateHighlighted];
    }
    
    /***************************
     Do no Delete
     We might need this code in future.
     *****************************/
    
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
        
        self.isOpenedFromPushNotification ? (ratingController.displaySource = kNotification) : (ratingController.displaySource = kRatingList);
    }
    else if([segue.identifier isEqualToString:@"segueDetailsToTrack"])
    {
        KSTrackTaxiController *trackTaxi = (KSTrackTaxiController*) segue.destinationViewController;
        //trackTaxi.taxiNo = self.tripInfo.taxi.number;
        //trackTaxi.jobId = self.tripInfo.jobId;
        
        trackTaxi.trip = self.tripInfo;
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
    
    if (self.btnCancelBooking.tag == BtnStateBookAgain) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                              action:@"btnBookAgainTapped"
                                                               label:[NSString stringWithFormat:@"jobId:%@",self.tripInfo.jobId]
                                                               value:nil] build]];
        
        UINavigationController *controller = [UIStoryboard mainRootController];
        KSBookingMapController *bookingController = (KSBookingMapController *)[controller.viewControllers firstObject];
        bookingController.repeatTrip = self.tripInfo;
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KSSetBookingSelected" object:nil];
    }
    else{
        [self showAlertForCancelBooking];
    }
}


#pragma mark - Private Functions 
-(void) updateStatusOfTaxi
{
    NSInteger status = [self.tripInfo.status integerValue];
    [self.imgStatus setHidden:FALSE];
    [self.lblStatus setHidden:FALSE];
    switch (status) {
        case KSTripStatusOpen:
            [self.imgStatus setImage:[UIImage imageNamed:@"scheduled-bar"]];
            [self.lblStatus setText:@"Your booking has been scheduled!"];
            break;
        case KSTripStatusInProcess:
        case KSTripStatusManuallyAssigned:
            [self.imgStatus setImage:[UIImage imageNamed:@"Booking-details-inprocess-bar"]];
            [self.lblStatus setText:@"Booking is in process, will assign soon!"];
            //[self.imgStatus setImage:[UIImage imageNamed:@"in-process-tag.png"]];
            break;
        case KSTripStatusTaxiAssigned:
            [self.imgStatus setImage:[UIImage imageNamed:@"Booking-deatils-confirmed-bar"]];
            //[self.lblStatus setText:@"Your booking has confirmed, taxi will arrived soon!"];
            [self.lblStatus setText:[NSString stringWithFormat:@"Your booking has confirmed, %@ will arrived soon!",[AppUtils taxiLimo:_tripInfo.vehicleType]]];
            //[self.imgStatus setImage:[UIImage imageNamed:@"confirmed-tag.png"]];
            break;
        case KSTripStatusCancelled:
            [self.imgStatus setImage:[UIImage imageNamed:@"Booking-details-cancelled-bar"]];
            [self.lblStatus setText:@"Your have cancelled this booking"];
            //[self.imgStatus setImage:[UIImage imageNamed:@"cancelled-tag.png"]];
            break;
        case KSTripStatusTaxiNotFound:
            [self.imgStatus setImage:[UIImage imageNamed:@"Booking-details-unavailable-bar"]];
            //[self.lblStatus setText:@"Taxi not available, please try again later"];
            [self.lblStatus setText:[NSString stringWithFormat:@"%@ not available, please try again later",[AppUtils taxiLimo:_tripInfo.vehicleType]]];
            //[self.imgStatus setImage:[UIImage imageNamed:@"taxi-unavailable-tag.png"]];
            break;
        case KSTripStatusComplete:
            [self.imgStatus setImage:[UIImage imageNamed:@"Booking-details-completed-bar"]];
            [self.lblStatus setText:@"Trip has been completed!"];
            break;
        default:
            [self.imgStatus setHidden:TRUE];
            [self.lblStatus setHidden:TRUE];
            break;
    }
}


-(void) showAlertForCancelBooking
{
    KSConfirmationAlertAction *okAction = [KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
        
        [self cancelBooking];
        
    }];
    
    KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel" handler:^(KSConfirmationAlertAction *action) {
        
    }];
    [KSConfirmationAlert showWithTitle:nil
                               message:@"Are you sure you want to cancel your booking?"
                              okAction:okAction
                          cancelAction:cancelAction];
    
}


-(void) showHideTrackATaxiButton
{
    if (self.tripInfo.taxi == nil) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [_btnTrack setTitle:[NSString stringWithFormat:@"Track my %@",[AppUtils taxiLimo:self.tripInfo.vehicleType]]
               forState:UIControlStateNormal]; //[AppUtils taxiLimo:self.tripInfo.vehicleType];
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
    
    NSString * phone = [[KSSessionInfo currentSession] phone];
    NSString * sessionId = [[KSSessionInfo currentSession] sessionId];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                          action:@"btnCancelBookingTapped"
                                                           label:[NSString stringWithFormat:@"jobId:%@ | Phone: %@ | SessionID: %@",self.tripInfo.jobId,phone,sessionId]
                                                           value:nil] build]];
    
    
    [KSDAL cancelTrip:self.tripInfo completion:^(KSAPIStatus status, id response) {
       
        [hud hide:YES];
        if (KSAPIStatusSuccess == status || KSAPIStatusInvalidJob == status) {
            //KSAPIStatusInvalidJob == status is added after very long discussion with Asif bahi, on 4th of Nov 2015 around 7:30 AM.
            //[self.navigationController popViewControllerAnimated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            //NSLog(@"%s,cancel booking unSuccess \n Response is %@",__func__,response);
            KSStringFromAPIStatus(status);
            
            [KSAlert show:KSStringFromAPIStatus(status)
                    title:@"Error"
                 btnTitle:@"OK"];
            
        }
        
    }];
}
@end
