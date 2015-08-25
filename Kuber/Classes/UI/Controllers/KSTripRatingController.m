//
//  KSTripRatingController.m
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTripRatingController.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Event handlers

- (IBAction)onClickDone:(id)sender {

    if (self.serviceRating.rate <= 3.0) {
        //If service rating is less then 3. Then show users a popup with options.
        NSLog(@"Rating is less then 3");
        self.serviceIssueView.hidden = false;
    }
    
    //Old Working code
    /*if (!self.serviceRatingView.rate || !self.driverRatingView.rate) {
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

    KSTripRating *tripRating = [KSDAL tripRatingForTrip:self.trip];
    [KSDAL rateTrip:self.trip withRating:tripRating completion:completionHandler];*/

}

@end
