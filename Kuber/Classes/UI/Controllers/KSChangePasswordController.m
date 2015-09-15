//
//  KSChangePasswordController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSChangePasswordController.h"

@interface KSChangePasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onClickSave:(id)sender;

@end

@implementation KSChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addHeadAndFooterToTableView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Change Password"];
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

#pragma mark - Private Functions
-(void) addHeadAndFooterToTableView
{
    self.tableView.allowsSelection = NO;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 45.0)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0,self.tableView.frame.size.width-10 , 30)];
    labelView.text = @"PASSWORD";
    labelView.font = [UIFont fontWithName:@"MuseoForDell-300" size:14];
    labelView.textColor = [UIColor colorFromHexString:@"#187a89"];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - Events

- (IBAction)onClickSave:(id)sender {
#ifndef __KS_DISABLE_VALIDATIONS
    NSString *error = nil;
    
    if (!self.txtCurrentPassword.text.length) {
        error = KSErrorNoPassword;
    }
    else if (!self.txtNewPassword.text.length) {
        error = KSErrorNoNewPassword;
    }
    else if ([self.txtNewPassword.text isEqualToString:self.txtCurrentPassword.text]) {
        error = KSErrorPasswordsMatch;
    }
    else if (![self.txtNewPassword.text isEqualToString:self.txtConfirmPassword.text]) {
        error = KSErrorPasswordsMismatch;
    }
    if (error) {
        [KSAlert show:error];
        return;
    }
#endif

    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [KSDAL updateUserPassword:self.txtCurrentPassword.text withPassword:self.txtNewPassword.text completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"inputCellIdentifier"];
    UIColor *color = [UIColor colorFromHexString:@"#999999"];
    
    if (indexPath.row == 0) {
        
        self.txtCurrentPassword = (KSTextField*)[cell viewWithTag:4001];
        self.txtCurrentPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Current Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtCurrentPassword.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"password.png"]];
    }
    else if(indexPath.row == 1){
        
        self.txtNewPassword = (KSTextField*)[cell viewWithTag:4001];
        self.txtNewPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtNewPassword.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"password.png"]];
        
    }
    else if (indexPath.row == 2){
        
        self.txtConfirmPassword = (KSTextField*)[cell viewWithTag:4001];
        self.txtConfirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtConfirmPassword.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"password.png"]];
    }
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
