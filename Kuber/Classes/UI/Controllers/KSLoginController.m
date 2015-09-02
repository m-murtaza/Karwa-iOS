//
//  ViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSLoginController.h"

#import "SWRevealViewController.h"

#import "KSResetPasswordController.h"
#import "KSVerifyController.h"

#import "KSDAL.h"
#import "MBProgressHUD.h"


@interface KSLoginController ()

@property (weak, nonatomic) IBOutlet UITextField *txtMobile;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)onClickLogin:(id)sender;

@end

@implementation KSLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Login"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navTest:(id)sender {
    [self.navigationController popToNthController:2 animated:YES];
}

- (void)addTestViewController {

    NSArray *colors = [NSArray arrayWithObjects:
                       [UIColor blackColor],
                       [UIColor redColor],
                       [UIColor darkGrayColor],
                       [UIColor greenColor],
                       [UIColor cyanColor],
                       [UIColor yellowColor],
                       [UIColor lightGrayColor],
                       [UIColor orangeColor],
                       [UIColor magentaColor],
                       nil];

    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = [[UIView alloc] initWithFrame:self.view.bounds];
    controller.view.backgroundColor = colors[self.navigationController.viewControllers.count % colors.count];

    [self.navigationController pushViewController:controller animated:YES];
    
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTestViewController)];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(navTest:)];
}

- (IBAction)onClickLogin:(id)sender {

    NSString *phone = self.txtMobile.text;
    NSString *password = self.txtPassword.text;
#ifndef __KS_DISABLE_VALIDATIONS
    NSString *error = nil;
    if (![phone isPhoneNumber]) {
        error = KSErrorPhoneValidation;
    }
    else if (!password.length) {
        error = KSErrorNoPassword;
    }
    if (error) {
        [KSAlert show:error];
        return;
    }
#endif

    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    UIViewController *me = self;
    [KSDAL loginUserWithPhone:phone password:password completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (KSAPIStatusSuccess == status) {
            UIViewController *controller = [UIStoryboard mainRootController];
            [me.revealViewController setFrontViewController:controller animated:YES];
            [me.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        } else {
            [KSAlert show:KSStringFromAPIStatus(status)];
            // Go to verify screen, if user is registered but not verified
            if (KSAPIStatusUserNotVerified == status) {
                KSVerifyController *controller = (KSVerifyController *)[UIStoryboard verifyController];
                controller.phone = phone;
                
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
                
                [self.navigationController pushViewController:controller animated:YES];
                
            }
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[KSResetPasswordController class]]) {
        KSResetPasswordController* controller = segue.destinationViewController;
        controller.mobileNumber = self.txtMobile.text;
    }
}

@end
