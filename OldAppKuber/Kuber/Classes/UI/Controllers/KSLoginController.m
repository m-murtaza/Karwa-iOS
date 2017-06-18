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

#import "ABManager.h"

@interface KSLoginController ()

@property (weak, nonatomic) IBOutlet KSTextField *txtMobile;

@property (weak, nonatomic) IBOutlet KSTextField *txtPassword;
@property (nonatomic, weak) IBOutlet UIButton *btnForgotPassword;

- (IBAction)onClickLogin:(id)sender;

@end

@implementation KSLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnForgotPassword.titleLabel.font = [UIFont fontWithName:KSMuseoSans300 size:13];
    
    [self setLeftViewOfTextBox];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Login"];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[self.txtMobile becomeFirstResponder];
    
    [self performSelector:@selector(selectPhoneField) withObject:nil afterDelay:0.5];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private Function

-(void) selectPhoneField
{
    [self.txtMobile becomeFirstResponder];
}
-(void) setLeftViewOfTextBox
{
    [self.txtPassword setRightViewMode:UITextFieldViewModeAlways];
    self.txtPassword.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pass-ico.png"]];
    
    [self.txtMobile setRightViewMode:UITextFieldViewModeAlways];
    self.txtMobile.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone.png"]];
    [self.txtMobile setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImage *img = [UIImage imageNamed:@"phonecode.png"];
    UIImageView *imgVeiw = [[UIImageView alloc] initWithImage:img];
    imgVeiw.contentMode = UIViewContentModeTop;
    [imgVeiw setFrame:CGRectMake(0, 0, img.size.width, img.size.height+2.5)];
    self.txtMobile.leftView = imgVeiw;
    
}

#pragma mark - Gesture
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.txtMobile resignFirstResponder];
        [self.txtPassword resignFirstResponder];
    }
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    //[self.view endEditing:YES];
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

#pragma mark - UITextField delegate 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *imgName;
    
    if ([textField isEqual:self.txtMobile]) {
        
        imgName = @"box-focused.png";
    }
    else if([textField isEqual:self.txtPassword]){
        imgName = @"box-focused.png";
    }

    [textField setBackground:[UIImage imageNamed:imgName]];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *imgName;
    if ([textField.text isEqualToString:@""] || nil == textField.text) {
        if ([textField isEqual:self.txtMobile]) {
            
            imgName = @"box-idle.png";
        }
        else if([textField isEqual:self.txtPassword]){
            imgName = @"box-idle.png";
        }
    }
    else {
        if ([textField isEqual:self.txtMobile]) {
            
            imgName = @"box-focused.png";
        }
        else if([textField isEqual:self.txtPassword]){
            imgName = @"box-focused.png";
        }
    }
    
    [textField setBackground:[UIImage imageNamed:imgName]];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.txtMobile]) {
        
        NSString *mobileNumber = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (mobileNumber.length > phoneNumberLength) {
            
            return FALSE;
        }
    }
    return TRUE;
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
    
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];

    NSString *phone = self.txtMobile.text;
    NSString *password = self.txtPassword.text;
#ifndef __KS_DISABLE_VALIDATIONS
    NSString *error = nil;
    if (![phone isQatarPhoneNumber]) {
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
        }
        else if (KSAPIStatusInvalidPassword == status){
            
            [KSAlert show:@"Invalid phone number or password"];
        }
        else if(KSAPIStatusUserNotVerified == status){
            KSVerifyController *controller = (KSVerifyController *)[UIStoryboard verifyController];
            controller.phone = phone;
            
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [self APICallFailAction:status];
            // Go to verify screen, if user is registered but not verified
            /*if (KSAPIStatusUserNotVerified == status) {
                KSVerifyController *controller = (KSVerifyController *)[UIStoryboard verifyController];
                controller.phone = phone;
                
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
                
                [self.navigationController pushViewController:controller animated:YES];
                
            }*/
        }
    }];
}



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[KSResetPasswordController class]]) {
        [self.txtMobile resignFirstResponder];
        [self.txtPassword resignFirstResponder];
        KSResetPasswordController* controller = segue.destinationViewController;
        controller.mobileNumber = self.txtMobile.text;
    }
}

@end
