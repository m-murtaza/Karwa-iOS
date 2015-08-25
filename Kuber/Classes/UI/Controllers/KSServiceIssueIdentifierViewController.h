//
//  KSServiceIssueIdentifierViewController.h
//  Kuber
//
//  Created by Asif Kamboh on 8/25/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSServiceIssueIdentifierViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *issueList;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
