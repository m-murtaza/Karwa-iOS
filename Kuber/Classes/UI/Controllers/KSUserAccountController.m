//
//  KSUserAccountController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/21/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSUserAccountController.h"
#import "KSDAL.h"
#import "KSUser.h"



@interface KSUserAccountController ()

//@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
//
//@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
//
//@property (weak, nonatomic) IBOutlet UILabel *lblName;


//@property (weak, nonatomic) IBOutlet UITableView *tblView;
-(IBAction)btnSaveTapped:(id)sender;
@end

@implementation KSUserAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    user = [KSDAL loggedInUser];

    [KSGoogleAnalytics trackPage:@"Edit Profile"];
}

#pragma mark -
#pragma mark - UIEvents

-(IBAction)btnSaveTapped:(id)sender{
    
    
    [self saveUserProfile];

}

#pragma mark -
#pragma mark - Private Methods

-(void) saveUserProfile
{

    NSString *updatedName = txtName ? txtName.text : @"";
    NSString *updatedEmail = txtEmail ? txtEmail.text: @"";
    
#ifndef __KS_DISABLE_VALIDATIONS
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:6];
    if (!updatedName.length) {
        [errors addObject:KSErrorNoUserName.localizedValue];
    }
    if (![updatedEmail isEmailAddress]) {
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
    [KSDAL updateUserInfoWithEmail:updatedEmail
                          withName:updatedName
                        completion:^(KSAPIStatus status, NSDictionary *data) {
        [hud hide:YES];
        if (status == KSAPIStatusSuccess) {
            [navController popViewControllerAnimated:YES];
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
}
#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
//
//}

#pragma mark - Table view Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    switch (section) {
        case 0:
            numRows = 3;
            break;
        case 1:
            numRows = 1;
            break;
        default:
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCellIdentifier"];
        UILabel *lbl = (UILabel*) [cell.contentView viewWithTag:2001];
        KSUITextFieldInCell *txt = (KSUITextFieldInCell*) [cell.contentView viewWithTag:2002];
        txt.section = indexPath.section;
        txt.row = indexPath.row;
        txt.delegate = self;

        switch (indexPath.row) {
            case 0:
                [lbl setText:@"Full Name"];
                txt.text = user.name;
                break;
            case 1:
                [lbl setText:@"Email"];
                txt.text = user.email;
                break;
            case 2:
                [lbl setText:@"Mobile Number"];
                txt.text = user.phone;
                [txt setUserInteractionEnabled:FALSE];
                break;
            default:
                break;
        }
        
    }
    else{
    
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChangePassCellIdentifier"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
}

#pragma mark - UITextFieldDelegate
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    KSUITextFieldInCell *txt = (KSUITextFieldInCell*) textField;
    if (txt.row == 0) {
       
        txtName = txt;
    }
    else{
        txtEmail = txt;
    }
}
@end
