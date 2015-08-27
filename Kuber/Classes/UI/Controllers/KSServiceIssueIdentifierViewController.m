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
    
    return [issueList count]+1;

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
        if (NSNotFound == [self idxPathInSelectedList:indexPath]) {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"issueOtherCellIdentifier"];
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

#pragma mark - UItextField delegate 

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"I am UItextField delegate");
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - View Adjectment 
- (void)keyboardWillShow:(NSNotification *)notification
{
    // Assign new frame to your view
    [UIView animateWithDuration:0.38 animations:^{
    [self.view setFrame:CGRectMake(0,-180,320,460)];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.38 animations:^{
        [self.view setFrame:CGRectMake(0,0,320,460)];
    }];
    
}
@end
