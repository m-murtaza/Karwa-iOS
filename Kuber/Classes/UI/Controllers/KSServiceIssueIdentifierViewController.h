//
//  KSServiceIssueIdentifierViewController.h
//  Kuber
//
//  Created by Asif Kamboh on 8/25/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSServiceIssueIdentifierViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSArray *issueList;
    NSMutableArray *selectedIndexs;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
