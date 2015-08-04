//
//  KSVerifyController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSVerifyController.h"
#import "SWRevealViewController.h"

#import "KSDAL.h"
#import "MBProgressHUD.h"

@interface KSVerifyController ()

@property (weak, nonatomic) IBOutlet UITextField *txtAccessCode;

- (IBAction)onClickVerify:(id)sender;

- (IBAction)onClickSendOtp:(id)sender;

@end

@implementation KSVerifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#ifndef __KS_DISABLE_VALIDATIONS
    NSAssert(self.phone.length, @"No phone number found");
#endif
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

- (IBAction)onClickVerify:(id)sender {
    if (self.txtAccessCode.text.length) {
        __block UIViewController *me = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [KSDAL verifyUserWithPhone:self.phone code:self.txtAccessCode.text completion:^(KSAPIStatus status, NSDictionary *data) {
            [hud hide:YES];
            if (KSAPIStatusSuccess == status) {
                UIViewController *controller = [UIStoryboard mainRootController];
                [me.revealViewController setFrontViewController:controller animated:YES];
                [me.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            } else {
                [KSAlert show:KSStringFromAPIStatus(status)];
            }
        }];
    }
}

- (IBAction)onClickSendOtp:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [KSDAL sendOtpOnPhone:self.phone completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (KSAPIStatusSuccess != status) {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];

}

@end
