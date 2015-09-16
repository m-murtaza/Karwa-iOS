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


@interface KSLoginController ()

@property (weak, nonatomic) IBOutlet UITextField *txtMobile;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (nonatomic, weak) IBOutlet UIButton *btnForgotPassword;

- (IBAction)onClickLogin:(id)sender;

@end

@implementation KSLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *color = [UIColor colorWithRed:123.0/256.0 green:169.0/256.0 blue:178.0/256.0 alpha:1.0];
    self.txtMobile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtMobile.font = [UIFont fontWithName:@"MuseoForDell-300" size:15.0];
    self.txtMobile.tintColor = [UIColor whiteColor];
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtPassword.font = [UIFont fontWithName:@"MuseoForDell-300" size:15.0];
    self.txtPassword.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    self.btnForgotPassword.titleLabel.font = [UIFont fontWithName:@"MuseoForDell-300" size:13];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Login"];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.txtMobile becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *imgName;
    
    if ([textField isEqual:self.txtMobile]) {
        
        imgName = @"phone-box-focused.png";
    }
    else if([textField isEqual:self.txtPassword]){
        imgName = @"password-box-focused.png";
    }

    [textField setBackground:[UIImage imageNamed:imgName]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *imgName;
    if ([textField.text isEqualToString:@""] || nil == textField.text) {
        if ([textField isEqual:self.txtMobile]) {
            
            imgName = @"phone-box-idle.png";
        }
        else if([textField isEqual:self.txtPassword]){
            imgName = @"password-box-idle.png";
        }
    }
    else {
        if ([textField isEqual:self.txtMobile]) {
            
            imgName = @"phone-box-focused.png";
        }
        else if([textField isEqual:self.txtPassword]){
            imgName = @"password-box-focused.png";
        }
    }
    
    [textField setBackground:[UIImage imageNamed:imgName]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return YES;
}


#pragma mark - View Adjectment
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, -100)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
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
