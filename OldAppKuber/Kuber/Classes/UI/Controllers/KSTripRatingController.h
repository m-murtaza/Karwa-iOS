//
//  KSTripRatingController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

#import "DYRateView.h"

typedef enum {
    kRatingList,
    kNotification,
    kMendatoryRating
} RatingViewDisplaySource;

@class KSTrip;
@class KSServiceIssueIdentifierViewController;

@interface KSTripRatingController : KSViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,DYRateViewDelegate>
{
    NSArray *issueList;
    NSMutableArray *selectedIndexs;
}

@property (nonatomic, strong) KSTrip *trip;

@property (weak, nonatomic) IBOutlet DYRateView *serviceRating;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *serviceIssueView;
@property (weak, nonatomic) KSServiceIssueIdentifierViewController *issueIdentifierViewController;

@property (nonatomic) RatingViewDisplaySource displaySource;



@end
