//
//  KSTripRatingController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTripRatingController.h"
#import "SWRevealViewController.h"
#import "KSMenuController.h"

#import "DYRateView.h"
#import "KSPlaceHolderTextView.h"

#define COMMENTS_MAX_LENGTH 512

@interface KSTripRatingController ()
{
    NSUInteger _rating;
    KSPlaceHolderTextView * _txtCommentView;
}

//@property (nonatomic, weak) IBOutlet DYRateView *serviceRatingView;
//@property (nonatomic, weak) IBOutlet DYRateView *driverRatingView;
//@property (nonatomic, weak) IBOutlet UITextView *txtComments;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropoffAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDropoffTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDropoffText;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpText;


//@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onClickDone:(id)sender;

@end

@implementation KSTripRatingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = nil;
    _rating = 0;
    
    self.serviceRating.delegate = self;
    [self addTableViewheader];
    [self setupView];
    //[self addGesture];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Rating View"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addTableViewheader
{
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 35.0)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 2.0,self.tableView.frame.size.width-10 , 30)];
    labelView.text = @"REASON BEHIND THIS RATING?";
    //labelView.adjustsFontSizeToFitWidth = FALSE;
    labelView.font = [UIFont fontWithName:KSMuseoSans300 size:12];
    labelView.font=[labelView.font fontWithSize:12];
    labelView.textColor = [UIColor colorFromHexString:@"#858585"];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
}

-(void) resignAllResponder
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignAllResponder];
}

-(void) addGesture
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];

}

-(void) setupView
{
    self.serviceRating.padding = 20;
    
    self.lblPickupDate.text = [self getFormattedTitleDate:self.trip.pickupTime];
    self.lblPickupTime.text = [self getTimeStringFromDate:self.trip.pickupTime];
    self.lblDropoffTime.text = [self getTimeStringFromDate:self.trip.dropOffTime];
    self.lblPickupAddress.text = self.trip.pickupLandmark ? self.trip.pickupLandmark : [NSString stringWithFormat:@"%@N , %@E",self.trip.pickupLat,self.trip.pickupLon];
    self.lblDropoffAddress.text = self.trip.dropoffLandmark ? self.trip.dropoffLandmark : @"-";
    
    selectedIndexs = [[NSMutableArray alloc] init];
    
    [self showLoadingView];
    [KSDAL syncIssueListWithCompletion:^(KSAPIStatus status, id response) {
        //TODO: Noting
        [self hideLoadingView];
        if (status == KSAPIStatusSuccess) {
            issueList = [NSArray arrayWithArray:[KSDAL allIssueList]];
            [self.tableView reloadData];
        }
        else {
            
            [KSAlert show:KSStringFromAPIStatus(status)];
            
        }
        
    }];
}
#pragma mark - Segue 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"SegueTripRatingToIssueIdentifier"]) {
        self.issueIdentifierViewController = (KSServiceIssueIdentifierViewController*)segue.destinationViewController;
    }
}

#pragma mark -
#pragma mark - Event handlers

- (IBAction)onClickDone:(id)sender {

    if (self.serviceRating.rate == 0 ) {
        [KSAlert show:@"Please select your rating first" title:@"Error"];
        return;
    }
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    void (^completionHandler)(KSAPIStatus, id) = ^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (KSAPIStatusSuccess == status) {
            if (self.isOpenedFromPushNotification) {
                
                UIViewController *controller = [UIStoryboard mainRootController];
                [self.revealViewController setFrontViewController:controller animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KSSetBookingSelected" object:nil];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    };

    KSTripRating *tripRating = [KSDAL tripRatingForTrip:self.trip];
    tripRating.serviceRating = [NSNumber numberWithFloat:self.serviceRating.rate];
    if (self.serviceRating.rate <= 3) {
        
        tripRating.issue = [self issueList];
    }
    else {
        tripRating.issue = @"";
        
    }
    tripRating.comments = _txtCommentView.text ? _txtCommentView.text : @"";
    [KSDAL rateTrip:self.trip withRating:tripRating completion:completionHandler];
    
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


-(NSString*) issueList
{
    NSArray *issues = [self selectedIssues];
    
    NSMutableString *strIssues = [NSMutableString stringWithString:@""];
    for(NSString *str in issues){

        [strIssues appendString:[NSString stringWithFormat:@"%@,",str]];
    }
    
    //Adding Comments
    /*if (_txtCommentView != nil && ![_txtCommentView.text isEqualToString:@""]) {
    
        [strIssues appendString:[NSString stringWithFormat:@"%@,",_txtCommentView.text]];
    }*/
    
    if (strIssues.length) {
        return (NSString*)[strIssues substringToIndex:[strIssues length]-1];
    }
    return @"";
    
    
}

-(NSArray*) selectedIssues
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSIndexPath *idx in selectedIndexs) {
        if(idx.row < issueList.count)
        {
            [arr addObject:[[issueList objectAtIndex:idx.row] valueEN]];
        }
    }
    return [NSArray arrayWithArray:arr];
}

#pragma mark - UItableview
/*-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    return 40;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.serviceRating.rate <= 3){
        return [issueList count]+1;
    }
    else {
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    if(self.serviceRating.rate <= 3 && indexPath.row < [issueList count]){
        
        height = 40;
    }
    else{

        height = 120;
    }
    
    return height;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    //if(self.serviceRating.rate <= 3){
        if (self.serviceRating.rate <= 3 && indexPath.row < [issueList count]) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceIssueCellIdentifier"];
            
            if(!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceIssueCellIdentifier"];
            }
            
            KSTripIssue *issue = [issueList objectAtIndex:indexPath.row];
            cell.textLabel.text = issue.valueEN;
            cell.textLabel.font = [UIFont fontWithName:KSMuseoSans300 size:15];
            cell.textLabel.textColor = [UIColor colorFromHexString:@"#777777"];
            
            //[UIColor colorWithRed:199/255 green:199/255 blue:199/255 alpha:1];
            
            if (NSNotFound == [self idxPathInSelectedList:indexPath]) {
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"issueOtherCellIdentifier"];
            _txtCommentView = (KSPlaceHolderTextView*)[cell viewWithTag:3001];
            _txtCommentView.placeholder = @"Comments..";
            _txtCommentView.placeholderColor = [UIColor colorFromHexString:@"#b5b5b5"];
            _txtCommentView.delegate = self;
        }
   // }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = [self idxPathInSelectedList:indexPath];
    if (NSNotFound == idx) {
        [selectedIndexs addObject:indexPath];
    }
    else {
        [selectedIndexs removeObjectAtIndex:idx];
    }
    [tableView reloadData];
}

-(NSInteger) idxPathInSelectedList:(NSIndexPath*)indexPath
{
    
    //NSNumber *num=[NSNumber numberWithInteger:indexPath.row];
    NSInteger anIndex=[selectedIndexs indexOfObject:indexPath];
    return anIndex;
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
     NSString *completeText = [NSString stringWithFormat:@"%@%@",textView.text,text];
    if (completeText.length >= COMMENTS_MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}
//- (BOOL)textFieldShouldReturn:(UITextField * _Nonnull)textField
//{
//    [textField resignFirstResponder];
//    return TRUE;
//    
//}

#pragma mark - Rating View Delegate
- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate
{
    if (_rating <= 3 && [rate integerValue] > 3) {
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(_rating > 3 && [rate integerValue] <= 3){
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    _rating = [rate integerValue];
    
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, -200)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}

#pragma mark - Gesture
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

@end
