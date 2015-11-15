//
//  KSSignupController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSSignupController.h"
#import "KSVerifyController.h"
#import "ABManager.h"

@interface KSSignupController ()
{

    BOOL isBackFromAnotherView;
}

@property (weak, nonatomic) IBOutlet KSTextField *txtEmail;
@property (weak, nonatomic) IBOutlet KSTextField *txtName;

@property (weak, nonatomic) IBOutlet KSTextField *txtMobile;

@property (weak, nonatomic) IBOutlet KSTextField *txtPassword;
@property (weak, nonatomic) IBOutlet KSTextField *txtConfirmPassword;


- (IBAction)onClickSignup:(id)sender;

@end

@implementation KSSignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isBackFromAnotherView = FALSE;
    
    [self setTransformValueForTextFields];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setLeftViewOfTextBox];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.txtName becomeFirstResponder];
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"Signup View Controller"];
    
    /*[self.txtEmail setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.txtName setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.txtMobile setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.txtPassword setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.txtConfirmPassword setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];*/
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
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
-(void) addTapGesture
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

#pragma mark - Private Function 

-(void) setLeftViewOfTextBox
{
    [self.txtName setRightViewMode:UITextFieldViewModeAlways];
    self.txtName.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"username.png"]];
    
    [self.txtEmail setRightViewMode:UITextFieldViewModeAlways];
    self.txtEmail.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email-signup.png"]];
    
    [self.txtMobile setRightViewMode:UITextFieldViewModeAlways];
    self.txtMobile.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone.png"]];
    
    [self.txtMobile setLeftViewMode:UITextFieldViewModeAlways];
    //self.txtMobile.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone.png"]];
    UIImage *img = [UIImage imageNamed:@"phonecode.png"];
    UIImageView *imgVeiw = [[UIImageView alloc] initWithImage:img];
    imgVeiw.contentMode = UIViewContentModeTop;
    [imgVeiw setFrame:CGRectMake(0, 0, img.size.width, img.size.height+2.5)];
    self.txtMobile.leftView = imgVeiw;
    
    [self.txtPassword setRightViewMode:UITextFieldViewModeAlways];
    self.txtPassword.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pass-ico.png"]];
    
    [self.txtConfirmPassword setRightViewMode:UITextFieldViewModeAlways];
    self.txtConfirmPassword.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pass-ico.png"]];
}



-(void) resignAllResponder
{
    [self.txtEmail resignFirstResponder];
    [self.txtName resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirmPassword resignFirstResponder];
}

#pragma mark - Gesture
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignAllResponder];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void) setTransformValueForTextFields
{
    UIColor *color = [UIColor colorWithRed:123.0/256.0 green:169.0/256.0 blue:178.0/256.0 alpha:1.0];
    
    self.txtName.transformVal = 0;
    self.txtName.focusedImg = @"box-focused.png";
    self.txtName.idleImg = @"box-idle.png";
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Full Name" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.txtEmail.transformVal = 0;
    self.txtEmail.focusedImg = @"box-focused.png";
    self.txtEmail.idleImg = @"box-idle.png";
    self.txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.txtMobile.transformVal = -50;
    self.txtMobile.focusedImg = @"box-focused.png";
    self.txtMobile.idleImg = @"box-idle.png";
    self.txtMobile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"XXX XXXXX" attributes:@{NSForegroundColorAttributeName: color}];
    
    
    self.txtPassword.transformVal = -100;
    self.txtPassword.focusedImg = @"box-focused.png";
    self.txtPassword.idleImg = @"box-idle.png";
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    
    self.txtConfirmPassword.transformVal = -180;
    self.txtConfirmPassword.focusedImg = @"box-focused.png";
    self.txtConfirmPassword.idleImg = @"box-idle.png";
    self.txtConfirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
}

- (IBAction)onClickSignup:(id)sender {
    
    [self signUp];
}

-(void) signUp
{
    [self resignAllResponder];
#ifndef __KS_DISABLE_VALIDATIONS
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:6];
    if (!self.txtName.text.length) {
        [errors addObject:KSErrorNoUserName.localizedValue];
    }
    if (![self.txtMobile.text isQatarPhoneNumber]) {
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

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.txtName]) {
        [self.txtEmail becomeFirstResponder];
    }
    else if([textField isEqual:self.txtEmail]){
        [self.txtMobile becomeFirstResponder];
    }
    else if([textField isEqual:self.txtPassword]){
        [self.txtConfirmPassword becomeFirstResponder];
    }
    else if([textField isEqual:self.txtConfirmPassword]){
        [self signUp];
    }
    
    //[textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if(!isBackFromAnotherView){
        KSTextField *txtField = (KSTextField*) textField;
        [txtField setBackground:[UIImage imageNamed:txtField.focusedImg]];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.view setTransform:CGAffineTransformMakeTranslation(0, txtField.transformVal)];
                             
                         }
                         completion:^(BOOL finished){
                             //tran = val;
                         }
         ];
//    }
//    else{
//        isBackFromAnotherView = FALSE;
//    }
    return TRUE;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    KSTextField *txtField = (KSTextField*) textField;
    if ([txtField.text isEqualToString:@""] || nil == textField.text) {
        
        [txtField setBackground:[UIImage imageNamed:txtField.idleImg]];
    }
    else{
        
        [txtField setBackground:[UIImage imageNamed:txtField.focusedImg]];
    }
    return TRUE;
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.txtEmail resignFirstResponder];
    [self.txtName resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirmPassword resignFirstResponder];
}
@end
