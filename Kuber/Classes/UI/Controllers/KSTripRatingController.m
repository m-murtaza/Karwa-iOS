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

#import "KSTrip.h"
#import "KSTripRating.h"

#import "KSDAL.h"

#import "MBProgressHUD.h"

@interface KSTripRatingController ()

@property (nonatomic, weak) IBOutlet DYRateView *serviceRatingView;
@property (nonatomic, weak) IBOutlet DYRateView *driverRatingView;
@property (nonatomic, weak) IBOutlet UITextView *txtComments;

- (IBAction)onClickDone:(id)sender;

@end

@implementation KSTripRatingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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

@end
