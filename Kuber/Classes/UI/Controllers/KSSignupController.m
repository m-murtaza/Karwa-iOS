//
//  KSSignupController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSSignupController.h"

#import "KSDAL.h"
#import "KSUser.h"
#import "MBProgressHUD.h"
#import "KSVerifyController.h"

@interface KSSignupController ()

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtName;

@property (weak, nonatomic) IBOutlet UITextField *txtMobile;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;


- (IBAction)onClickSignup:(id)sender;

@end

@implementation KSSignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)onClickSignup:(id)sender {
#ifndef __KS_DISABLE_VALIDATIONS
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:6];
    if (!self.txtName.text.length) {
        [errors addObject:KSErrorNoUserName.localizedValue];
    }
    if (![self.txtMobile.text isPhoneNumber]) {
        [errors addObject:KSErrorPhoneValidation.localizedValue];
    }
    if (![self.txtEmail.text isEmailAddress]) {
        [errors addObject:KSErrorEmailValidation.localizedValue];
    }
    if (!self.txtPassword.text.length) {
        [errors addObject:KSErrorNoPassword.localizedValue];
    }
    else if (![self.txtPassword.text isEqualToString:self.txtConfirmPassword.text]) {
        [errors addObject:KSErrorPasswordsMismatch.localizedValue];
    }
    if (errors.count) {
        NSString *title = errors.count > 1 ? KSAlertTitleMultipleErrors : KSAlertTitleError;
        NSString *errorMessage = [errors componentsJoinedByString:@"\r\n"];
        [KSAlert show:errorMessage title:title];
        return;
    }
#endif
    KSUser *user = [KSDAL userWithPhone:self.txtMobile.text];
    user.name = self.txtName.text;
    user.email = self.txtEmail.text;

    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    [KSDAL registerUser:user password:self.txtPassword.text completion:^(KSAPIStatus statusCode, NSDictionary *data) {
        [hud hide:YES];
        if (statusCode == KSAPIStatusSuccess) {
            KSVerifyController *controller = (KSVerifyController *)[UIStoryboard verifyController];
            controller.phone = user.phone;

            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(statusCode)];
        }
    }];
}

@end
