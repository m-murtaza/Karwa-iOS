//
//  KSTripRatingController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTripRatingController.h"
#import "KSServiceIssueIdentifierViewController.h"

#import "DYRateView.h"
#import "KSPlaceHolderTextView.h"

@interface KSTripRatingController ()

@property (nonatomic, weak) IBOutlet DYRateView *serviceRatingView;
@property (nonatomic, weak) IBOutlet DYRateView *driverRatingView;
@property (nonatomic, weak) IBOutlet UITextView *txtComments;

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
    
    [self setupView];
    [self addGesture];

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
    
    self.lblDropoffText.font = [UIFont fontWithName:@"MuseoForDell-300" size:11];
    self.lblPickUpText.font = [UIFont fontWithName:@"MuseoForDell-300" size:11];
    
    selectedIndexs = [[NSMutableArray alloc] init];
    
    [KSDAL syncIssueListWithCompletion:^(KSAPIStatus status, id response) {
        //TODO: Noting
        NSLog(@"%@",response);
        issueList = [NSArray arrayWithArray:[KSDAL allIssueList]];
        [self.tableView reloadData];
    }];
}
#pragma mark - Segue 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"SegueTripRatingToIssueIdentifier"]) {
        self.issueIdentifierViewController = segue.destinationViewController;
    }
}

#pragma mark -
#pragma mark - Event handlers

- (IBAction)onClickDone:(id)sender {

    if (self.serviceIssueView.hidden == TRUE) {
        if (self.serviceRating.rate <= 3.0) {
            //If service rating is less then 3. Then show users a popup with options.
            NSLog(@"Rating is less then 3");
            self.serviceIssueView.hidden = false;
            self.issueIdentifierViewController.tripRatingView = self;
        }
    }
    
    else{
        
        if (!self.serviceRating.rate) {
            return;
        }
        
        __block UINavigationController *navController = self.navigationController;
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        void (^completionHandler)(KSAPIStatus, id) = ^(KSAPIStatus status, NSDictionary *data) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
                [navController popViewControllerAnimated:YES];
            }
            else {
                [KSAlert show:KSStringFromAPIStatus(status)];
            }
        };
        
        NSString *issues = [self issueList];
        NSLog(@"issues = %@",issues);
        
        
        KSTripRating *tripRating = [KSDAL tripRatingForTrip:self.trip];
        tripRating.issue = issues;
        
        [KSDAL rateTrip:self.trip withRating:tripRating completion:completionHandler];
    }
}

#pragma mark - Private Functions
-(NSString*) issueList
{
    NSArray *issues = [self.issueIdentifierViewController selectedIssues];
    
    NSMutableString *strIssues = [NSMutableString stringWithString:@""];
    for(NSString *str in issues){

        [strIssues appendString:[NSString stringWithFormat:@"%@,",str]];
    }
    return (NSString*)[strIssues substringToIndex:[strIssues length]-1];
    
}

-(NSArray*) selectedIssues
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSIndexPath *idx in selectedIndexs) {
        
        [arr addObject:[[issueList objectAtIndex:idx.row] valueEN]];
    }
    return [NSArray arrayWithArray:arr];
}

#pragma mark - UItableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [issueList count]+1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    if(indexPath.row < [issueList count]){
        
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
    if (indexPath.row < [issueList count]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceIssueCellIdentifier"];
        
        if(!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceIssueCellIdentifier"];
        }
        
        KSTripIssue *issue = [issueList objectAtIndex:indexPath.row];
        cell.textLabel.text = issue.valueEN;
        cell.textLabel.font = [UIFont fontWithName:@"MuseoForDell-300" size:15];
        cell.textLabel.textColor = [UIColor colorWithRed:199/255 green:199/255 blue:199/255 alpha:1];
        
        if (NSNotFound == [self idxPathInSelectedList:indexPath]) {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"issueOtherCellIdentifier"];
        KSPlaceHolderTextView *txtView = (KSPlaceHolderTextView*)[cell viewWithTag:3001];
        txtView.placeholder = @"Comments..";
        txtView.placeholderColor = [UIColor colorFromHexString:@"#b5b5b5"];
        txtView.delegate = self;
    }
    
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
