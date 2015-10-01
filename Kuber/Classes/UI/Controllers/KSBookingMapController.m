//
//  KSBookingMapController.m
//  Kuber
//
//  Created by Asif Kamboh on 9/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingMapController.h"

//Utilities
#import "KSLocationManager.h"
#import "KSConfirmationAlert.h"

//ViewControllers & Views
#import "KSAddressPickerController.h"
#import "KSBookingDetailsController.h"
#import "KSDatePicker.h"


#define ADDRESS_CELL_HEIGHT         86.0
#define TIME_CELL_HEIGHT            66.0
#define BTN_CELL_HEIGHT             77

#define TXT_TITLE_PICKUP_ADDRESS    @"PICKUP ADDRESS"
#define TXT_TITLE_DROPOFF_ADDRESS   @"DROPOFF ADDRESS"
#define TXT_TITLE_PICKUP_TIME       @"PICKUP TIME"

@interface KSBookingMapController () <KSAddressPickerDelegate,KSDatePickerDelegate>
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
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *lblLocationLandMark;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tblViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomMapToTopTblView;
@property (nonatomic, weak) IBOutlet UIButton *btnCurrentLocaiton;

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
    
    dropoffVisible = FALSE;
    [self setIndexForCell:dropoffVisible];

    mapLoadForFirstTime = TRUE;
    
    
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
    [self addTableViewHeader];
    [self.btnCurrentLocaiton setSelected:TRUE];
    
}

#pragma mark - Private Function

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
    if (dropoffVisible) {
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"downarrow-idle.png"] forState:UIControlStateNormal];
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"downarrow-pressed.png"] forState:UIControlStateHighlighted];
    }
    else {
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"uparrow-idle.png"] forState:UIControlStateNormal];
        [self.btnDestinationReveal setImage:[UIImage imageNamed:@"uparrow-pressed.png"] forState:UIControlStateHighlighted];
    }
}

-(void) addTableViewHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 2.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    [imageView setImage:[UIImage imageNamed:@"bottombx-topbar.png"]];
    [headerView addSubview:imageView];
    
    self.tableView.tableHeaderView = headerView;
}


-(void) bookTaxi
{
    
    NSString * pickup = [NSString stringWithFormat:@"%@, %@",hintTxt,self.lblPickupLocaiton.text];
    
    tripInfo = [KSDAL tripWithLandmark:pickup
                                   lat:self.mapView.centerCoordinate.latitude
                                   lon:self.mapView.centerCoordinate.longitude];
    
    
    if (self.lblDropoffLocaiton.text.length) {
        
        tripInfo.dropoffLandmark = self.lblDropoffLocaiton.text;
        tripInfo.dropOffLat = [NSNumber numberWithDouble:dropoffPoint.latitude];
        tripInfo.dropOffLon = [NSNumber numberWithDouble:dropoffPoint.longitude];
    }
       
    KSDatePicker *datePicker = (KSDatePicker *)self.txtPickupTime.inputView;
    
    tripInfo.pickupTime = datePicker.date;
    
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [KSDAL bookTrip:tripInfo completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            NSLog(@"%@",data);
            KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
                NSLog(@"%s OK Handler", __PRETTY_FUNCTION__);
                [self performSegueWithIdentifier:@"segueBookingToDetail" sender:self];
                
            }];
            NSString *str = [NSString stringWithFormat:@"We have received your booking request for %@ at %@. We are working on it. You will receive a confirmaiton message in few minutes",[tripInfo.pickupTime getFormattedTitleDate],[tripInfo.pickupTime getTimeStringFromDate]];
            
            
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
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"Please provide some hint"
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
         txtField.placeholder = @"Please provide some hint";
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MMM dd, yy, HH:mm"];
    [formatter setDateFormat:@"dd - MMMM yyyy, hh:mm a"];
    
    self.txtPickupTime.text = [formatter stringFromDate:date];
}

-(void) setMapRegionToUserCurrentLocation
{
    //Zoom map to users current location
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.00001;
    span.longitudeDelta = 0.00001;
    
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    region.span = span;
    region.center = location;
    
    [_mapView setRegion:region animated:TRUE];
    [_mapView regionThatFits:region];
}

-(void) setPickupLocationLblText
{

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
        
            DLog(@"Address is not found for %f - %f",self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
        }
        
        
    }];
    
}

#pragma mark - MapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation     *)userLocation
{
    mapView.showsUserLocation = NO;
    if (mapLoadForFirstTime) {
        mapLoadForFirstTime = FALSE;
        [self setMapRegionToUserCurrentLocation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    [self setCurrentLocaitonBtnState];
    [self setPickupLocationLblText];
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
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"pickupTimeCellIdentifier"];
        UILabel *lblTitle = (UILabel*) [cell viewWithTag:6003];
        [lblTitle setText:TXT_TITLE_PICKUP_TIME];
        if (!self.txtPickupTime.text.length) {
            
            self.txtPickupTime = (UITextField*) [cell viewWithTag:6004];
            [self updatePickupTime:[NSDate date]];
            [self addDataPickerToTxtPickupTime];
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
    if (indexPath.row == idxPickupLocation || indexPath.row == idxDropOffLocation) {
        
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
    }
    else if([segue.identifier isEqualToString:@"segueBookingToDetail"]) {
        
        KSBookingDetailsController *bookingDetails = (KSBookingDetailsController *) segue.destinationViewController;
        bookingDetails.tripInfo = tripInfo;
    }
}

#pragma mark - AddressPicker Delegate

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location {

    if(picker.pickerId == KSPickerIdForPickupAddress){
        
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

#pragma mark - UI Events

- (IBAction) btnShowDestinationTapped:(id)sender
{

    if (dropoffVisible) {
        
        dropoffVisible = FALSE;
        [self setIndexForCell:dropoffVisible];
        
        
        
        
        NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
        [arrayOfIndexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        [self.tableView layoutIfNeeded];
        [self.btnCurrentLocaiton setHidden:FALSE];
        self.tblViewHeight.constant -= 94;
        self.bottomMapToTopTblView.constant +=94;
        [UIView animateWithDuration:0.5 animations:^{
            [self.tableView layoutIfNeeded];
            
            [self.tableView deleteRowsAtIndexPaths:arrayOfIndexPaths
                                  withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    }
    else {
        
        dropoffVisible = TRUE;
        [self setIndexForCell:dropoffVisible];
        NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
        [arrayOfIndexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        [self.tableView layoutIfNeeded];
        [self.btnCurrentLocaiton setHidden:TRUE];
        self.tblViewHeight.constant += 94;
        self.bottomMapToTopTblView.constant -=94;
        [UIView animateWithDuration:1.0 animations:^{
            [self.tableView layoutIfNeeded];
            [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths
                                  withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    
    [self UpdateMapForDropOff:dropoffVisible];
    [self setDestinationRevealBtnState];
    [self setAddressTextStatus];
}

- (IBAction)showCurrentLocationTapped:(id)sender
{
    NSInteger locationStatus = [CLLocationManager authorizationStatus];
    
    if(locationStatus == kCLAuthorizationStatusRestricted || locationStatus == kCLAuthorizationStatusDenied){
        
        KSConfirmationAlertAction *okAction =[KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [KSConfirmationAlert showWithTitle:nil
                                   message:@"Location Services Disabled. Please enable location services."
                                  okAction:okAction];
    }
    else
    {
        self.mapView.showsUserLocation = YES;
        [self.mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
    }
}

- (IBAction) btnBookingRequestTapped:(id)sender
{
    [self showAlertWithHint];
}

@end
