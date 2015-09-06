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
- (IBAction)onClickSave:(id)sender;

@end

@implementation KSChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
@end
