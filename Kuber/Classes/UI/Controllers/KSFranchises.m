//
//  KSFranchises.m
//  Kuber
//
//  Created by Asif Kamboh on 10/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSFranchises.h"
#import "UIImageView+AFNetworking.h"

@interface KSFranchises () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *franchisesList;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end
@implementation KSFranchises
-(void) viewDidLoad{
    
    [super viewDidLoad];
    franchisesList = [NSArray array];
    [self showLoadingView];
    [KSDAL syncFranchiseWithCompletion:^(KSAPIStatus status, id response) {
        if (status == KSAPIStatusSuccess) {
            
            franchisesList = [KSDAL allFranchises];
            [self.tableView reloadData];
            [self hideLoadingView];
        }
        else{
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return franchisesList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125.0;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"franchiseCellIdentifier"];
    
    KSFranchise * franchise = [franchisesList objectAtIndex:indexPath.row];
    
    UIImageView *imgView = (UIImageView*) [cell viewWithTag:1050];
    
    [imgView setImageWithURL:[NSURL URLWithString:franchise.logoUrl]];
    
    return cell;
}
@end
