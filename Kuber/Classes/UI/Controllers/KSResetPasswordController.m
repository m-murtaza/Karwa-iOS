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

@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

- (IBAction)onClickResetPassword:(id)sender;

@end

@implementation KSResetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtMobile.text = self.mobileNumber;
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

@end
