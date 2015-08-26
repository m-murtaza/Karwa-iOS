//
//  KSServiceIssueIdentifierViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 8/25/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSServiceIssueIdentifierViewController.h"
#import "KSDAL+TripIssue.h"
#import "KSTripIssue.h"

@interface KSServiceIssueIdentifierViewController ()

@end

@implementation KSServiceIssueIdentifierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedIndexs = [[NSMutableArray alloc] init];
    
    [KSDAL syncIssueListWithCompletion:^(KSAPIStatus status, id response) {
        //TODO: Noting
        NSLog(@"%@",response);
        issueList = [NSArray arrayWithArray:[KSDAL allIssueList]];
        [self.tableView reloadData];
    }];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [issueList count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceIssueCellIdentifier"];
    
    if(!cell) {
    
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceIssueCellIdentifier"];
    }
    
    KSTripIssue *issue = [issueList objectAtIndex:indexPath.row];
    cell.textLabel.text = issue.valueEN;
    if (NSNotFound == [self idxPathInSelectedList:indexPath]) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
@end
