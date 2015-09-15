//
//  KSResetPasswordController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/18/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSResetPasswordController.h"

#include "KSVerifyController.h"

#include "KSDAL.h"
#include "MBProgressHUD.h"

@interface KSResetPasswordController ()

@property (weak, nonatomic) IBOutlet KSTextField *txtMobile;
@property (weak, nonatomic) IBOutlet KSTextField *txtPassword;
@property (weak, nonatomic) IBOutlet KSTextField *txtConfirmPassword;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onClickResetPassword:(id)sender;

@end

@implementation KSResetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.txtMobile.text = self.mobileNumber;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 35.0)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 2.0,self.tableView.frame.size.width-10 , 30)];
    labelView.text = @"ACCOUNT INFO";
    labelView.font = [UIFont fontWithName:@"MuseoForDell-300" size:12];
    labelView.textColor = [UIColor colorFromHexString:@"#858585"];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Forgot Password"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickResetPassword:(id)sender {
#ifndef __KS_DISABLE_VALIDATIONS
    NSString *error = nil;
    if (![self.txtMobile.text isPhoneNumber]) {
        error = KSErrorPhoneValidation;
    }
    else if (!self.txtPassword.text.length) {
        error = KSErrorNoPassword;
    }
    else if (![self.txtPassword.text isEqualToString:self.txtConfirmPassword.text]) {
        error = KSErrorPasswordsMismatch;
    }
    if (error) {
        [KSAlert show:error];
        return;
    }
#endif
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *phone = self.txtMobile.text;
    [KSDAL resetPasswordForUserWithPhone:self.txtMobile.text password:self.txtPassword.text completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            KSVerifyController *controller = (KSVerifyController *)[UIStoryboard verifyController];
            controller.phone = phone;

            [self.navigationController pushViewController:controller animated:YES];
            
            controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPasswordReset:)];

        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
}

- (void)cancelPasswordReset:(id)sender {
    [self.navigationController popToNthController:2 animated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"inputCellIdentifier"];
    if (indexPath.row == 0) {
        
        self.txtMobile = (KSTextField*)[cell viewWithTag:4001];
        self.txtMobile.placeholder = @"Mobile number";
        self.txtMobile.text = self.mobileNumber;
        self.txtMobile.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"option-check.png"]];
    }
    else if(indexPath.row == 1){
        
        self.txtPassword = (KSTextField*)[cell viewWithTag:4001];
        self.txtPassword.placeholder = @"Password";
        self.txtPassword.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"option-check.png"]];
    
    }
    else if (indexPath.row == 2){
        
        self.txtConfirmPassword = (KSTextField*)[cell viewWithTag:4001];
        self.txtConfirmPassword.placeholder = @"Confirm Password";
        self.txtConfirmPassword.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"option-check.png"]];
    }
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
