//
//  KSAccountEditController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/22/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAccountEditController.h"
#import "MBProgressHUD.h"


@interface KSAccountEditController ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

- (IBAction)onClickSave:(id)sender;

@end

@implementation KSAccountEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"AccountEdit"];
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
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:6];
    if (!self.txtName.text.length) {
        [errors addObject:KSErrorNoUserName.localizedValue];
    }
    if (![self.txtEmail.text isEmailAddress]) {
        [errors addObject:KSErrorEmailValidation.localizedValue];
    }
    if (errors.count) {
        NSString *title = errors.count > 1 ? KSAlertTitleMultipleErrors : KSAlertTitleError;
        NSString *errorMessage = [errors componentsJoinedByString:@"\r\n"];
        [KSAlert show:errorMessage title:title];
        return;
    }
#endif
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    __block UINavigationController *navController = self.navigationController;
    [KSDAL updateUserInfoWithEmail:self.txtEmail.text withName:self.txtName.text completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            [navController popViewControllerAnimated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
}

@end
