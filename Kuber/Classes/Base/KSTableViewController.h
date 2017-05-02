//
//  KSTableViewController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KSTableViewDataSource <UITableViewDataSource>

@required

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

@interface KSTableViewController : UITableViewController<KSTableViewDataSource>

- (void)reloadTableViewData;
- (void)setNoDataMessage:(NSString *)message;

-(void) APICallFailAction:(KSAPIStatus) status;
@end

