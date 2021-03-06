//
//  KSVerifyController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSVerifyController.h"
#import "SWRevealViewController.h"
#define __KS_DISABLE_VALIDATIONS 1

@interface KSVerifyController ()

@property (weak, nonatomic) IBOutlet UITextField *txtAccessCode;
@property (weak, nonatomic) IBOutlet UIButton *btnVarify;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;

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
    
    //[self addTapGesture];
    [self adjustUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Verify View Controller"];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.txtAccessCode becomeFirstResponder];
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

#pragma mark - private functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.txtAccessCode resignFirstResponder];
    }
}

-(void) adjustUI
{
    UIColor *color = [UIColor colorWithRed:123.0/256.0 green:169.0/256.0 blue:178.0/256.0 alpha:1.0];
    self.txtAccessCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter verification code here" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtAccessCode.font = [UIFont fontWithName:@"MuseoForDell-300" size:15.0];
    self.txtAccessCode.tintColor = [UIColor whiteColor];
    
    self.btnResend.titleLabel.font = [UIFont fontWithName:@"MuseoForDell-300" size:13];
    //self.btnVarify.titleLabel.font = [];
}

-(void) addTapGesture
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

#pragma mark - Gesture
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark - Event handler
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
                [self APICallFailAction:status];
            }
        }];
    }
    else{
        
        [KSAlert show:@"Please enter varification code" title:@"Error"];
    }
}

- (IBAction)onClickSendOtp:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [KSDAL sendOtpOnPhone:self.phone completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (KSAPIStatusSuccess != status) {
            [self APICallFailAction:status];
        }
        else {
            
                [self APICallFailAction:status];
            }
        
    }];

}

@end
