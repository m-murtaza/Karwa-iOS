//
//  KSTripRatingController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

#import "DYRateView.h"


@class KSTrip;
@class KSServiceIssueIdentifierViewController;

@interface KSTripRatingController : KSViewController

@property (nonatomic, strong) KSTrip *trip;

@property (weak, nonatomic) IBOutlet DYRateView *serviceRating;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *serviceIssueView;
@property (weak, nonatomic) KSServiceIssueIdentifierViewController *issueIdentifierViewController;



@end
