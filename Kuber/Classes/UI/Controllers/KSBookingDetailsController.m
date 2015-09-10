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
@property (weak, nonatomic) IBOutlet UILabel *lblPickupDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAcknowlegement;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelBooking;
@property (weak, nonatomic) IBOutlet UILabel *lblDropoffTime;
@property (weak, nonatomic) IBOutlet UIView *dropoffContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleTaxiInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet UILabel *lblTaxiNumber;

@property (weak, nonatomic) IBOutlet UIView *viewTaxiInfo;


@end

@implementation KSBookingDetailsController

- (BOOL)isValidLat:(NSNumber *)lat lon:(NSNumber *)lon {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    return [CLLocation isValidCoordinate:coordinate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadViewData];
}


-(void) loadViewData
{
    KSTrip *trip = self.tripInfo;
    
    //Set Pickup Address
    if (trip.pickupLandmark.length) {
        
        self.lblPickupAddress.text = trip.pickupLandmark;
    }
    else  if ([self isValidLat:trip.pickupLat lon:trip.pickupLon]){
        
        self.lblPickupAddress.text = KSStringFromCoordinate(CLLocationCoordinate2DMake(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue));
    }
    
    //Set Drop Off Address
    if (trip.dropoffLandmark.length) {
        
        self.lblDropoffAddress.text = trip.dropoffLandmark;
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
    if (trip.taxi == nil) {
        
        [self hideTaxiInfo:trip];
    }
    else {
        KSDriver *driver = trip.driver;
        self.lblDriverName.text = driver.name;
        self.lblDriverNumber.text = driver.phone ;

        KSTaxi *taxi = trip.taxi;
        self.lblTaxiNumber.text = taxi.number;
        
    }
}


-(void) setStatusForTrip:(KSTrip*)trip
{
    switch (trip.status.integerValue) {
        case KSTripStatusOpen:
        case KSTripStatusInProcess:
            if (self.showsAcknowledgement) {
                //[self.btnCancelBooking removeFromSuperview];
                [self.btnCancelBooking setHidden:YES];
            }
            else {
                //[self.lblAcknowlegement removeFromSuperview];
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
    timeFormatter.dateFormat = @"HH:mm";
    
    
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
