//
//  KSBookingMapController.m
//  Kuber
//
//  Created by Asif Kamboh on 9/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingMapController.h"

//ThirdParty
#import <Crashlytics/Crashlytics.h>

//Utilities
#import "KSLocationManager.h"
#import "KSConfirmationAlert.h"

//ViewControllers & Views
#import "KSAddressPickerController.h"
#import "KSBookingDetailsController.h"
#import "KSDatePicker.h"
#import "KSVehicleTrackingAnnotation.h"
#import "KSPointAnnotation.h"
#import "KSVehicleAnnotationView.h"
#import "NYSegmentedControl.h"
#import "AppUtils.h"


#define ADDRESS_CELL_HEIGHT         86.0
#define TIME_CELL_HEIGHT            66.0
#define BTN_CELL_HEIGHT             77

#define TXT_TITLE_PICKUP_ADDRESS    @"PICKUP ADDRESS"
#define TXT_TITLE_DROPOFF_ADDRESS   @"DROPOFF ADDRESS"
#define TXT_TITLE_PICKUP_TIME       @"PICKUP TIME"

#define DOHA_LATITUDE               25.2867
#define DOHA_LONGITUDE              51.5333

#define MAX_TAXI_ANNOTATIONS        (10)

#define TXT_HINT_TAG                1019
#define MAX_PICKUP_TEXT             225
#define MAX_HINT_DETAIL_COUNT       5
#define DETAIL_HINT_KEY             @"dtailCountKey"

@interface KSBookingMapController () <KSAddressPickerDelegate,KSDatePickerDelegate,UITextFieldDelegate>
{
  
    //This will identify if map is loaded for the first time.
    BOOL mapLoadForFirstTime;
    
    NSInteger idxPickupLocation;
    NSInteger idxDropOffLocation;
    NSInteger idxPickupTime;
    NSInteger idxBtnCell;
    
    BOOL dropoffVisible;
    
    NSString *hintTxt;
    KSTrip *tripInfo;
    CLLocationCoordinate2D dropoffPoint;
    BOOL isMaploaded;
    BOOL isPickupFromMap;                 //Used for analytics
    
    KSVehicleType vehicleType;              //This is for service type i.e. limo or taxi
    NYSegmentedControl *segmentVehicleType;     //Vehicletype limo or texi on top navigation bar
    NYSegmentedControl *segmantLimoType;        //Limo type: Standard, Business, Luxury
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *lblLocationLandMark;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tblViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomMapToTopTblView;
@property (nonatomic, weak) IBOutlet UIButton *btnCurrentLocaiton;
@property (nonatomic, weak) IBOutlet UIView *mapDisableView;
@property (nonatomic, weak) IBOutlet UIImageView *imgDestinationHelp;
@property (nonatomic, strong) UILabel *lblPickupLocaitonTitle;
@property (nonatomic, strong) UILabel *lblPickupLocaiton;
@property (nonatomic, strong) UITextField *txtPickupTime;
@property (nonatomic, strong) UILabel *lblDropoffLocaiton;
@property (nonatomic, strong) UIButton *btnDestinationReveal;


//Top Right navigation item
- (IBAction)showCurrentLocationTapped:(id)sender;
- (IBAction) btnShowDestinationTapped:(id)sender;
- (IBAction) btnBookingRequestTapped:(id)sender;

@end

@implementation KSBookingMapController

-(void) viewDidLoad
{
    
    [super viewDidLoad];
    
//    NSString *strdate = @"2017-04-18T13:43:13.22+03:00";
//    NSDate *date = [strdate dateValue];
//    
//    DLog(@"%@",date);
    //firstTimeLoad = TRUE;
    isMaploaded = FALSE;
    dropoffVisible = FALSE;
    isPickupFromMap = TRUE;
    vehicleType = KSCityTaxi;
    [self setIndexForCell:dropoffVisible];

    
    if (self.repeatTrip) {
        //[self populateOldTripData];
        mapLoadForFirstTime = FALSE;
    }
    else{
        mapLoadForFirstTime = TRUE;
    }
    
    
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
    
    [self addTableViewHeader];
    //[self.btnCurrentLocaiton setSelected:TRUE];
    [self addCrashlyticsInfo];
    
    
    [self.mapDisableView setHidden:FALSE];
    
    if(IS_IPHONE_5)
    {
        [self.imgDestinationHelp setImage:[UIImage imageNamed:@"destination-help-iphone5.png"]];
    }
    
    [self addVehicleTypeSegment];
    [self createLimoTypeSegmant];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Map Booking Screen"];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkLocationAvaliblityAndShowAlert];
    
    //Patch for iOS 9 other wise animation was bit odd.
    
    [self showhideDropOff];
    if (self.repeatTrip) {
     
        [self populateOldTripData];
    }
    
}

#pragma mark - Limo Type Segment Control
-(void) createLimoTypeSegmant
{
    //Segment Control
    segmantLimoType = [[NYSegmentedControl alloc] initWithItems:@[@"STANDARD", @"BUSINESS",@"LUXURY"]];
    
    segmantLimoType.titleTextColor = [UIColor whiteColor];//[UIColor colorWithRed:0.082f green:0.478f blue:0.537f alpha:1.0f];
    segmantLimoType.selectedTitleTextColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];
    segmantLimoType.selectedTitleFont = [UIFont systemFontOfSize:13.0f];//[UIFont fontWithName:KSMuseoSans700 size:5];
    segmantLimoType.titleFont = [UIFont systemFontOfSize:13.0f];//[UIFont fontWithName:KSMuseoSans700 size:10.0];
    segmantLimoType.segmentIndicatorBackgroundColor = [UIColor whiteColor];
    segmantLimoType.backgroundColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];

    segmantLimoType.borderWidth = 0.0f;
    segmantLimoType.segmentIndicatorBorderWidth = 0.0f;
    segmantLimoType.segmentIndicatorInset = 2.0f;
    segmantLimoType.segmentIndicatorBorderColor = self.view.backgroundColor;
    //[segmantLimoType setFrame:CGRectMake(20, 5, 300, 35)];
    //[segmantLimoType sizeToFit] ;
    segmantLimoType.cornerRadius = CGRectGetHeight(segmantLimoType.frame) / 2.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    segmantLimoType.usesSpringAnimations = YES;
#endif
    
    [segmantLimoType addTarget:self action:@selector(onSegmentLimoTypeChange) forControlEvents:UIControlEventValueChanged];
}
-(IBAction)onSegmentLimoTypeChange
{
    switch (segmantLimoType.selectedSegmentIndex) {
        case 0:
            vehicleType = KSStandardLimo;
            break;
        case 1:
            vehicleType = KSBusinessLimo;
            break;
        case 2:
            vehicleType = KSLuxuryLimo;
            break;
        default:
            break;
    }
    [self updateTaxisInCurrentRegion];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                          action:@"Booking - Limo Type Selection"
                                                           label:[NSString stringWithFormat:@"Selected Type %@",[AppUtils vehicleTypeToString:vehicleType]]
                                                           value:nil] build]];
}

#pragma mark - Vehicle Type Segment Control

//This function is to add UI and have lot of hardcode values.
// This control will be visible on top navigation bar.
-(void) addVehicleTypeSegment
{
    //Segment Control
    segmentVehicleType = [[NYSegmentedControl alloc] initWithItems:@[@"Taxi", @"Limo"]];
    
    segmentVehicleType.titleTextColor = [UIColor colorWithRed:0.082f green:0.478f blue:0.537f alpha:1.0f];
    segmentVehicleType.selectedTitleTextColor = [UIColor whiteColor];
    segmentVehicleType.selectedTitleFont = [UIFont fontWithName:KSMuseoSans500 size:30.0];
    segmentVehicleType.titleFont = [UIFont fontWithName:KSMuseoSans500 size:20.0];
    segmentVehicleType.segmentIndicatorBackgroundColor = [UIColor colorWithRed:0.0f green:0.476f blue:0.527f alpha:1.0f];
    segmentVehicleType.backgroundColor = [UIColor whiteColor];
    segmentVehicleType.borderWidth = 0.0f;
    segmentVehicleType.segmentIndicatorBorderWidth = 0.0f;
    segmentVehicleType.segmentIndicatorInset = 2.0f;
    segmentVehicleType.segmentIndicatorBorderColor = self.view.backgroundColor;
    [segmentVehicleType setFrame:CGRectMake(self.view.frame.size.width / 2 -150, 13, 200, 35)];
    segmentVehicleType.cornerRadius = CGRectGetHeight(segmentVehicleType.frame) / 2.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    segmentVehicleType.usesSpringAnimations = YES;
#endif
    
    [segmentVehicleType addTarget:self action:@selector(onSegmentVehicleTypeChange) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView =segmentVehicleType;
}

- (IBAction)onSegmentVehicleTypeChange
{
    if(segmentVehicleType.selectedSegmentIndex == 0)
        [self updateUIForTaxi];
    else
        [self updateUIForLimo];
    [self updateTaxisInCurrentRegion];
    [_tableView reloadData];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                          action:@"Booking - Vehicle Type Selection"
                                                           label:[NSString stringWithFormat:@"Selected Type %@",(segmentVehicleType.selectedSegmentIndex == 0) ? @"Tax" : @"Limo"]
                                                           value:nil] build]];

}

-(void) updateUIForTaxi
{
    vehicleType = KSCityTaxi;
    [self updateTaxisInCurrentRegion];
}
-(void) updateUIForLimo
{
    switch (segmantLimoType.selectedSegmentIndex) {
        case 0:
            vehicleType = KSStandardLimo;
            break;
        case 1:
            vehicleType = KSBusinessLimo;
            break;
        case 2:
            vehicleType = KSLuxuryLimo;
            break;
        default:
            break;
    }
    [self onSegmentLimoTypeChange];
}

#pragma mark - Private Function

-(void) populateOldTripData
{
    [self setMapRegionToLat:[self.repeatTrip.pickupLat doubleValue] Long:[self.repeatTrip.pickupLon doubleValue]];
    
    if(self.repeatTrip.dropoffLandmark.length){
        self.lblDropoffLocaiton.text = self.repeatTrip.dropoffLandmark;
        dropoffPoint = CLLocationCoordinate2DMake([self.repeatTrip.dropOffLat doubleValue], [self.repeatTrip.dropOffLon doubleValue]);
    }
    
    if (self.repeatTrip.pickupHint.length) {
        hintTxt = self.repeatTrip.pickupHint;
    }
    
    vehicleType = (KSVehicleType)[self.repeatTrip.vehicleType integerValue];
    
    if([AppUtils isTaxiType: vehicleType])
        [segmentVehicleType setSelectedSegmentIndex:0];
    else
    {
        [segmentVehicleType setSelectedSegmentIndex:1];
        
        [self.tableView reloadData];
    }
    
    
    
    //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([tripInfo.pickupLat doubleValue], [tripInfo.pickupLon doubleValue]) animated:YES];
    
}

-(void) addCrashlyticsInfo
{
    KSUser *user = [KSDAL userWithPhone:[[KSSessionInfo currentSession] phone] ];
    [[Crashlytics  sharedInstance] setObjectValue:user.phone forKey:@"Crashlytics_User_Id"];
    [[Crashlytics  sharedInstance] setObjectValue:user.name forKey:@"Crashlytics_User_Name"];
    [[Crashlytics  sharedInstance] setObjectValue:[[KSSessionInfo currentSession] sessionId] forKey:@"Crashlytics_Session_Id"];
    
}


-(void) setCurrentLocaitonBtnState
{
    float mapCenterLat = [[NSString stringWithFormat:@"%.4f", self.mapView.centerCoordinate.latitude] floatValue];
    float mapCenterLon = [[NSString stringWithFormat:@"%.4f", self.mapView.centerCoordinate.longitude] floatValue];

    float userLocationLat = [[NSString stringWithFormat:@"%.4f", self.mapView.userLocation.location.coordinate.latitude] floatValue];
    float userLocationLon = [[NSString stringWithFormat:@"%.4f", self.mapView.userLocation.location.coordinate.longitude] floatValue];
    
    if (mapCenterLat == userLocationLat && mapCenterLon == userLocationLon) {
        
        [self.btnCurrentLocaiton setSelected:TRUE];
    }
    else{
        [self.btnCurrentLocaiton setSelected:FALSE];
    }
}

-(void) setAddressTextStatus
{
    if (dropoffVisible) {
        [self.lblPickupLocaitonTitle setTextColor:[UIColor colorFromHexString:@"#cee7fb"]];
        [self.lblPickupLocaiton setTextColor:[UIColor colorFromHexString:@"#dddddd"]];
    }
    else{
        [self.lblPickupLocaitonTitle setTextColor:[UIColor colorFromHexString:@"#25aaf1"]];
        [self.lblPickupLocaiton setTextColor:[UIColor colorFromHexString:@"#000000"]];
    }
    
}

-(void) setDestinationRevealBtnState{
    /*if (dropoffVisible) {
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"downarrow-idle.png"] forState:UIControlStateNormal];
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"downarrow-pressed.png"] forState:UIControlStateHighlighted];
    }
    else {
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"uparrow-idle.png"] forState:UIControlStateNormal];
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"uparrow-pressed.png"] forState:UIControlStateHighlighted];
    }*/
}

-(void) addTableViewHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 2.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    [imageView setImage:[UIImage imageNamed:@"bottombx-topbar.png"]];
    [headerView addSubview:imageView];
    
    self.tableView.tableHeaderView = headerView;
}

-(NSString*) completePickUpAddress:(NSString*)hint Pickup:(NSString*)pickUpadd
{
    return [NSString stringWithFormat:@"%@, %@",hint,pickUpadd];
}

-(void) resetDropoffHintConter
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:DETAIL_HINT_KEY];
    [defaults synchronize];
}

-(BOOL) showHintForDestination
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *hintCount = [defaults objectForKey:DETAIL_HINT_KEY];
    if ([hintCount integerValue] >= MAX_HINT_DETAIL_COUNT || hintCount == nil) {
        [self resetDropoffHintConter];
        return TRUE;
    }
    hintCount = [NSNumber numberWithInt:[hintCount intValue]+1];
    [defaults setObject:hintCount forKey:DETAIL_HINT_KEY];
    [defaults synchronize];
    return FALSE;
}

-(void) hideHintView:(BOOL)hide
{
    if (hide)
    {
        self.mapView.userInteractionEnabled = TRUE;
        self.imgDestinationHelp.hidden = TRUE;
    }
    else {
        [self.view endEditing:TRUE];
        self.mapView.userInteractionEnabled = FALSE;
        self.imgDestinationHelp.hidden = FALSE;
    }
}

-(void) bookTaxi
{
    
    if(self.lblDropoffLocaiton.text.length == 0 || [self.lblDropoffLocaiton.text isEqualToString:@"---"])
    {
        if ([self showHintForDestination]) {
            [self hideHintView:FALSE];
            return;
        }
    }
    
    tripInfo = [KSDAL tripWithLandmark:self.lblPickupLocaiton.text
                                   lat:self.mapView.centerCoordinate.latitude
                                   lon:self.mapView.centerCoordinate.longitude];
    
    if (self.lblDropoffLocaiton.text.length && ![self.lblDropoffLocaiton.text isEqualToString:@"---"]) {
        [self resetDropoffHintConter];
        tripInfo.dropoffLandmark = self.lblDropoffLocaiton.text;
        tripInfo.dropOffLat = [NSNumber numberWithDouble:dropoffPoint.latitude];
        tripInfo.dropOffLon = [NSNumber numberWithDouble:dropoffPoint.longitude];
    }
    
    KSDatePicker *datePicker = (KSDatePicker *)self.txtPickupTime.inputView;
    
    if([AppUtils isTaxiType:vehicleType])
        tripInfo.pickupTime = datePicker.date;
    else
        tripInfo.pickupTime = [NSDate date];
    
    tripInfo.pickupHint = hintTxt ? hintTxt : @"";

    tripInfo.vehicleType = [NSNumber numberWithInt:vehicleType];
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [KSDAL bookTrip:tripInfo completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        
        if (status == KSAPIStatusSuccess) {
            NSLog(@"%@",data);
            KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
                NSLog(@"%s OK Handler", __PRETTY_FUNCTION__);
                [self performSegueWithIdentifier:@"segueBookingToDetail" sender:self];
                
            }];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                  action:[AppUtils vehicleTypeToString:vehicleType]
                                                                   label:isPickupFromMap ? @"Address Pick from Map" : @"Address Pick from Address Picker"
                                                                   value:nil] build]];
            
            NSString *str;
            if ([tripInfo.bookingType isEqualToString:KSBookingTypeCurrent]) {
                
                str = [NSString stringWithFormat:@"We have received your booking request for %@. You will receive a confirmation message in few minutes",[tripInfo.pickupTime formatedDateForBooking]];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                      action:@"CurrentTaxiBooking"
                                                                       label:[NSString stringWithFormat:@"TripInfo: %@",tripInfo]
                                                                       value:nil] build]];
            }
            else{
                
                str = [NSString stringWithFormat:@"We have received your booking request for %@. Thank you for choosing Karwa.",[tripInfo.pickupTime formatedDateForBooking]];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                      action:@"AdvTaxiBooking"
                                                                       label:[NSString stringWithFormat:@"TripInfo: %@",tripInfo]
                                                                       value:nil] build]];
            }
            
            
            [KSConfirmationAlert showWithTitle:nil
                                       message:str
                                      okAction:okAction];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
        
    }];
    
}

-(void) showAlertWithHint
{
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"Please provide additional pickup information."
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *alertRef = alt;
    UIAlertAction *okAction = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // access text from text field
                                   NSString *text = ((UITextField *)[alertRef.textFields objectAtIndex:0]).text;
                                   
                                   if (!text.length) {
                                       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                       
                                       [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                            action:@"btnHintOkTap"
                                                            label:@"No Input"
                                                            value:nil]
                                                      build]];
                                       
                                       [self showAlertWithHint];
                                   }
                                   else{
                                       hintTxt = ((UITextField *)[alertRef.textFields objectAtIndex:0]).text;
                                       [self bookTaxi];
                                   }
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                               
                                                           }];
    [alt addTextFieldWithConfigurationHandler:^(UITextField *txtField)
     {
         txtField.placeholder = @"e.g. Villaggio Gate No.2";
         txtField.autocapitalizationType = UITextAutocapitalizationTypeWords;
         txtField.delegate = self;
         txtField.tag = TXT_HINT_TAG;
         txtField.text = hintTxt ? hintTxt : @"";
     }];
    [alt addAction:okAction];
    [alt addAction:cancelAction];
    [self presentViewController:alt animated:YES completion:nil];
}

-(void) addDataPickerToTxtPickupTime
{
    NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:0];
    // Max date should be 15 day ahead only
    NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:30 * 24 * 60 * 60];
    
    //NSDate *date = minDate;
    
    KSDatePicker *picker = [[KSDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    picker.minimumDate = minDate;
    picker.maximumDate = maxDate;
    
    picker.delegate = self;
    
    self.txtPickupTime.inputView = picker;
    [self updatePickupTime:[NSDate date]];
}

-(void) UpdateMapForDropOff:(BOOL) withDropOff
{
    if (withDropOff) {
        self.mapView.scrollEnabled = FALSE;
    }
    else{
        self.mapView.scrollEnabled = TRUE;
    }
}

-(void) setIndexForCell:(BOOL)withDropOff
{
    if (withDropOff) {
        
        idxPickupLocation = 0;
        idxDropOffLocation = 1;
        idxPickupTime = 2;
        idxBtnCell = 3;
    }
    else {
        
        idxPickupLocation = 0;
        idxPickupTime = 1;
        idxBtnCell = 2;
        idxDropOffLocation = 100; //
        
    }
}

- (void)updatePickupTime:(NSDate *)date {
    
    
    
    self.txtPickupTime.text = [date formatedDateForBooking];
}

-(void) updatePickupTimeIfNeeded
{
    KSDatePicker *datePicker = (KSDatePicker *)self.txtPickupTime.inputView;
    if ([datePicker.date isInPast]) {

        [self updatePickupTime:[NSDate date]];
        datePicker.picker.date = [NSDate date];
    }
}

-(void) setMapRegionToLat:(CLLocationDegrees)lat Long:(CLLocationDegrees)lon
{
    //Zoom map to users current location
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
    region.span = span;
    region.center = location;
    
    [_mapView setRegion:region animated:TRUE];
    //[_mapView regionThatFits:region];
    
    [self performSelector:@selector(reversGeoCodeMapLocation)
               withObject:nil afterDelay:1.5];
}

-(void) setMapRegionToUserCurrentLocation
{
    
    
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    [self setMapRegionToLat:location.latitude Long:location.longitude];
    
}

-(void) setPickupLocationLblText
{
    
    isPickupFromMap = TRUE;
    //Firstly only show the lat long
    [self.lblPickupLocaiton setText:[NSString stringWithFormat:@"%f - %f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude]];
    self.lblLocationLandMark.text = self.lblPickupLocaiton.text;
    //Then reverse geocode the lat long
    [[KSLocationManager instance] locationWithCoordinate:self.mapView.centerCoordinate completion:^(KSGeoLocation *geolocation) {
        
        if (geolocation.address) {
            DLog(@"Address is found for %f - %f is %@",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude,geolocation.address);

            
            [self.lblPickupLocaiton setText:geolocation.address];
            self.lblLocationLandMark.text = self.lblPickupLocaiton.text;
            //[self.lblPickupLocaiton setText:@"Mowasalt Apartments Al Sadd, Al Saffa Polyclinic, Doha"];
        }
        else {
        
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                  action:@"Reverse geocode not found"
                                                                   label:[NSString stringWithFormat:@"coordinate %f-%f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude]
                                                                   value:nil] build]];
            DLog(@"Address is not found for %f - %f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
        }
        
        
    }];
    
}

-(BOOL) checkLocationAvaliblityAndShowAlert
{
    BOOL locationAvailable = TRUE;
    NSInteger locationStatus = [CLLocationManager authorizationStatus];
    
    if(locationStatus == kCLAuthorizationStatusRestricted || locationStatus == kCLAuthorizationStatusDenied || locationStatus == kCLAuthorizationStatusNotDetermined){
        locationAvailable = FALSE;
        KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [KSConfirmationAlert showWithTitle:nil
                                   message:@"Location services are disabled. Please enable location services."
                                  okAction:okAction];
    }
    return locationAvailable;
}

-(void) updateViewForShowHideDropOff
{
    [self UpdateMapForDropOff:dropoffVisible];
    [self setDestinationRevealBtnState];
    [self setAddressTextStatus];
}

-(void)showhideDropOff
{
    if (dropoffVisible == FALSE) {
        
        [self showDropOff:FALSE];
        [self hideDropOff:FALSE];
    }
}

-(void) showDropOff:(BOOL)animated
{
    if (dropoffVisible == FALSE) {
        
        dropoffVisible = TRUE;
        [self setIndexForCell:dropoffVisible];
        NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
        [arrayOfIndexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        //[self.tableView layoutIfNeeded];
        [self.btnCurrentLocaiton setHidden:TRUE];
        
        self.tblViewHeight.constant += 94;
        self.bottomMapToTopTblView.constant -=94;
        //[self.tableView layoutIfNeeded];
        NSTimeInterval animDuration = animated ? 0.5 : 0;
        
        [UIView animateWithDuration:animDuration animations:^{
            [self.tableView layoutIfNeeded];
            [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.mapDisableView setAlpha:0.6];
        } completion:^(BOOL finished) {
            if (animated) {
                //[self.mapDisableView setHidden:FALSE];
            }
            
        }];
        
        [self updateViewForShowHideDropOff];
    }
}

-(void) hideDropOff:(BOOL)animated
{
    if (dropoffVisible == TRUE) {

        dropoffVisible = FALSE;
        [self setIndexForCell:dropoffVisible];
        
        NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
        [arrayOfIndexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        [self.tableView layoutIfNeeded];
        [self.btnCurrentLocaiton setHidden:FALSE];
        
        self.tblViewHeight.constant -= 94;
        self.bottomMapToTopTblView.constant +=94;
        
        NSTimeInterval animDuration = animated ? 0.5 : 0;
        
        [UIView animateWithDuration:animDuration animations:^{
            [self.tableView layoutIfNeeded];
            
            [self.tableView deleteRowsAtIndexPaths:arrayOfIndexPaths
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.mapDisableView setAlpha:0.0];
        } completion:^(BOOL finished) {
            if (animated) {
                //[self.mapDisableView setHidden:TRUE];
            }
            
        }];
        
        [self updateViewForShowHideDropOff];
    }
}

- (void)updateTaxisInCurrentRegion {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    CLLocationCoordinate2D center = _mapView.centerCoordinate;
    CLLocationCoordinate2D left = [_mapView convertPoint:CGPointMake(0, _mapView.frame.size.height/1.3 ) toCoordinateFromView:_mapView];
    
    CLLocationDistance radius;
    if([AppUtils isTaxiType:vehicleType])
    {
        radius = [[CLLocation locationWithCoordinate:center] distanceFromLocation:[CLLocation locationWithCoordinate:left]];
    }
    else
    {
        radius = 10000000.0;                //Just a random big number. no need for constant.
    }
    [KSDAL vehiclesNearCoordinate:center radius:radius type:vehicleType completion:^(KSAPIStatus status, NSArray * vehicles) {
        
        NSMutableArray *vehiclesAnnotations = [NSMutableArray array];
        for (int counter = 0; counter < vehicles.count && counter < MAX_TAXI_ANNOTATIONS; counter++) {
            
            [vehiclesAnnotations addObject:[KSVehicleTrackingAnnotation annotationWithTrackingInfo:[vehicles objectAtIndex:counter]]];
        }
        NSArray *previusAnnotations = self.mapView.annotations;
        for (id annotation in previusAnnotations) {
            if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        [self.mapView addAnnotations:vehiclesAnnotations];
        
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TXT_HINT_TAG) {
        //textfield for hint
        NSString *str =  [self completePickUpAddress:[NSString stringWithFormat:@"%@%@",textField.text,string]
                                              Pickup:self.lblPickupLocaiton.text];
        NSLog(@"%lu",(unsigned long)str.length);
        if (str.length >= MAX_PICKUP_TEXT) {
            NSLog(@"Bas kar day bahi");
            return NO;
        }
    }
    
    return TRUE;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    if (!self.imgDestinationHelp.hidden) {
        [self hideHintView:TRUE];
        return FALSE;
    }
    return TRUE;
}


#pragma mark - MapViewDelegate

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    self.lblPickupLocaiton.text = @"Doha, Qatar";
    self.lblPickupLocaitonTitle.text = @"Doha, Qatar";
    [self setMapRegionToLat:DOHA_LATITUDE Long:DOHA_LONGITUDE];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation     *)userLocation
{
    mapView.showsUserLocation = NO;
    if (mapLoadForFirstTime) {
        mapLoadForFirstTime = FALSE;
        
        [self setMapRegionToUserCurrentLocation];
        
    }
    else{
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    }
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    if (isMaploaded) {
        
        [self setPickupLocationLblText];
        //[self setCurrentLocaitonBtnState];
        [self updateTaxisInCurrentRegion];
    }
    else{
       
        NSInteger locationStatus = [CLLocationManager authorizationStatus];
        
        if(locationStatus == kCLAuthorizationStatusRestricted || locationStatus == kCLAuthorizationStatusDenied || locationStatus == kCLAuthorizationStatusNotDetermined){
            [self setPickupLocationLblText];
            //[self setCurrentLocaitonBtnState];
        
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
        if ([annotation isKindOfClass:[MKUserLocation class]])
            return nil;
    
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[KSVehicleTrackingAnnotation class]]) {
        annotationView = (KSVehicleAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:[KSVehicleAnnotationView reuseIdentifier]];
        if (!annotationView) {
            annotationView = [[KSVehicleAnnotationView alloc] initWithAnnotation:annotation];
        }
        else {
            annotationView.annotation = annotation;
        }
    }
    return annotationView;
}

-(void) reversGeoCodeMapLocation
{
    [self setPickupLocationLblText];
    isMaploaded = TRUE;
    [self updateTaxisInCurrentRegion];
}

#pragma mark - UITableView Datasouce
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    switch (indexPath.row) {
        case 0:
            height = ADDRESS_CELL_HEIGHT;
            break;
        case 1:
            height = dropoffVisible ? ADDRESS_CELL_HEIGHT : TIME_CELL_HEIGHT;
            break;
        case 2:
            height = dropoffVisible ? TIME_CELL_HEIGHT : BTN_CELL_HEIGHT;
        default:
            height= BTN_CELL_HEIGHT;
            break;
    }
    return height;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dropoffVisible) {
        return 4;
    }
    return 3;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.row == idxPickupLocation){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"bookingCellIdentifier"];
        //UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"bookingCellIdentifier"];
        self.lblPickupLocaitonTitle = (UILabel*) [cell viewWithTag:6001];
        [self.lblPickupLocaitonTitle setText:TXT_TITLE_PICKUP_ADDRESS];
       
        if (!self.lblPickupLocaiton) {
            self.lblPickupLocaiton = (UILabel*) [cell viewWithTag:6002];
        }
    }
    else if(indexPath.row == idxDropOffLocation){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"bookingCellIdentifier"];
        UILabel *lblTitle = (UILabel*) [cell viewWithTag:6001];
        [lblTitle setText:TXT_TITLE_DROPOFF_ADDRESS];
        if (!self.lblDropoffLocaiton) {
            self.lblDropoffLocaiton = (UILabel*) [cell viewWithTag:6002];
        }
        
    }
    else if(indexPath.row == idxPickupTime){
        
        if([AppUtils isTaxiType:vehicleType])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"pickupTimeCellIdentifier"];
            UILabel *lblTitle = (UILabel*) [cell viewWithTag:6003];
            [lblTitle setText:TXT_TITLE_PICKUP_TIME];
            if (!self.txtPickupTime.text.length) {
                
                self.txtPickupTime = (UITextField*) [cell viewWithTag:6004];
                [self updatePickupTime:[NSDate date]];
                [self addDataPickerToTxtPickupTime];
            }
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"segmentCellIdentifier"];
            
            
            UIView *segmentView = [cell viewWithTag:101];
            //[segmentView setNeedsDisplay];
            
            segmantLimoType.frame = CGRectMake(0, 0, segmentView.frame.size.width, segmentView.frame.size.height);
            segmantLimoType.cornerRadius = CGRectGetHeight(segmantLimoType.frame) / 2.0f;
            
            
            switch (vehicleType) {
                case KSStandardLimo:
                    [segmantLimoType setSelectedSegmentIndex:0];
                    break;
                case KSBusinessLimo:
                    [segmantLimoType setSelectedSegmentIndex:1];
                    break;
                case KSLuxuryLimo:
                    [segmantLimoType setSelectedSegmentIndex:2];
                    break;
                default:
                    [segmantLimoType setSelectedSegmentIndex:0];
                    break;
            }
            //[segmentView setBackgroundColor:[UIColor orangeColor]];
            [segmentView addSubview:segmantLimoType];
            segmantLimoType.translatesAutoresizingMaskIntoConstraints = false;
            
            NSDictionary *viewBindings = NSDictionaryOfVariableBindings(segmentView,segmantLimoType);
            [segmentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[segmantLimoType]-0-|" options:0 metrics:nil views:viewBindings]];
            [segmentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[segmantLimoType]-0-|" options:0 metrics:nil views:viewBindings]];
            // put a breakpoint after this line to see the frame of your UIWebView.
            // It should be the same as the view
            [segmentView layoutIfNeeded];
            
        }
    }
    else if(indexPath.row == idxBtnCell){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"bookingBtnCellIdentifier"];
        self.btnDestinationReveal = (UIButton*) [cell viewWithTag:6005];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableView Delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imgDestinationHelp.hidden) {
        [self hideHintView:TRUE];
        return;
    }
    
    if (indexPath.row == idxPickupLocation) {
        
        if (dropoffVisible) {
            
            [self hideDropOff:TRUE];
        }
        else{
         
            [self performSegueWithIdentifier:@"segueBookingToAddressPicker" sender:self];
        }
    }
    else if(indexPath.row == idxDropOffLocation)
    {
        [self performSegueWithIdentifier:@"segueBookingToAddressPicker" sender:self];
    }
    else if(indexPath.row == idxPickupTime) {

        [self.txtPickupTime becomeFirstResponder];
    }
}

#pragma mark - DatePicker Delegate
- (void)datePicker:(KSDatePicker *)picker didPickDate:(NSDate *)date {
    
    [self.txtPickupTime resignFirstResponder];
    
    [self updatePickupTime:date];
}


#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueBookingToAddressPicker"]) {
        
        KSAddressPickerController *addressPicker = (KSAddressPickerController*) segue.destinationViewController;
        addressPicker.pickerId = dropoffVisible ? KSPickerIdForDropoffAddress :KSPickerIdForPickupAddress;
        addressPicker.delegate = self;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                              action:@"Navigate to Addresspicker"
                                                               label:addressPicker.pickerId
                                                               value:nil] build]];
    }
    else if([segue.identifier isEqualToString:@"segueBookingToDetail"]) {
        
        KSBookingDetailsController *bookingDetails = (KSBookingDetailsController *) segue.destinationViewController;
        bookingDetails.tripInfo = tripInfo;
    }
}

#pragma mark - AddressPicker Delegate

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location {

    if(picker.pickerId == KSPickerIdForPickupAddress){
        isPickupFromMap = FALSE;
        [self.lblPickupLocaiton setText:address];
        self.lblLocationLandMark.text = self.lblPickupLocaiton.text;
        if (location) {
            
            [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        }
    }
    else
    {
        [self.lblDropoffLocaiton setText:address];
        dropoffPoint = location.coordinate;
    }
}

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location hint:(NSString *)hint{
    
    if(picker.pickerId == KSPickerIdForPickupAddress){
        isPickupFromMap = FALSE;
        [self.lblPickupLocaiton setText:address];
        self.lblLocationLandMark.text = self.lblPickupLocaiton.text;
        if (location) {
            
            [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        }
        if (hint && ![hint isEqualToString:@""]) {
            hintTxt = hint;
        }
        else{
            hintTxt = @"";
        }
    }
    else
    {
        [self.lblDropoffLocaiton setText:address];
        dropoffPoint = location.coordinate;
    }
}

#pragma mark - UI Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    //[self.imgDestinationHelp setHidden:TRUE];
    [self hideHintView:TRUE];
}

- (IBAction) btnShowDestinationTapped:(id)sender
{
    if (!self.imgDestinationHelp.hidden) {
        [self hideHintView:TRUE];
    }
    
    if (dropoffVisible) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                              action:@"btnShowDestinationTapped"
                                                               label:@"Hide dropoff location"
                                                               value:nil] build]];
        
        [self hideDropOff:TRUE];
    }
    else {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                              action:@"btnShowDestinationTapped"
                                                               label:@"Show dropoff location"
                                                               value:nil] build]];
        
        [self showDropOff:TRUE];
    }
}

- (IBAction)showCurrentLocationTapped:(id)sender
{
    if (!self.imgDestinationHelp.hidden) {
        [self hideHintView:TRUE];
        return;
    }
    
    if ([self checkLocationAvaliblityAndShowAlert]) {
        
        //mapLoadForFirstTime = TRUE;
        self.mapView.showsUserLocation = YES;
        [self.mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
    }
    
}

- (IBAction) btnBookingRequestTapped:(id)sender
{
    if (!self.imgDestinationHelp.hidden) {
        [self hideHintView:TRUE];
        return;
    }
    //For Current booking if pickup time is in past then update pickup time.
    [self updatePickupTimeIfNeeded];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Input"
                                                          action:@"btnBookingRequestTapped"
                                                           label:[NSString stringWithFormat:@"Pickup: %@ | Dest: %@ | Time: %@",self.lblPickupLocaiton.text,self.lblDropoffLocaiton.text,self.txtPickupTime.text]
                                                           value:nil] build]];
    
    
    [self showAlertWithHint];

}

@end
