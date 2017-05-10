//
//  KSUserAccountController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/21/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSUserAccountController.h"
#import "KSAccountEditController.h"
#import "KSConfirmationAlert.h"

@interface KSUserAccountController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet KSLabel *lblName;
@property (nonatomic, weak) IBOutlet KSLabel *lblEmail;
@property (nonatomic, weak) IBOutlet KSLabel *lblPhone;
@property (nonatomic, weak) IBOutlet UILabel *lblVersion;


@end

@implementation KSUserAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addHeadAndFooterToTableView];
    [self UpdateVersion];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    user = [KSDAL loggedInUser];
    [self loadViewData];

    [KSGoogleAnalytics trackPage:@"Edit Profile"];
}

#pragma mark -
#pragma mark - Private Methods

-(void) UpdateVersion
{
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    _lblVersion.text = [NSString stringWithFormat:@"%@ %@ (%@)",_lblVersion.text,appVersionString,appBuildString];
}

-(void) loadViewData
{
    self.lblName.text = [user.name uppercaseString];
    self.lblName.font = [UIFont fontWithName:KSMuseoSans500 size:17];
    
    self.lblEmail.text = user.email;
    self.lblEmail.font = [UIFont fontWithName:KSMuseoSans300 size:12];
    
    self.lblPhone.text = user.phone;
    self.lblPhone.font = [UIFont fontWithName:KSMuseoSans300 size:12];
}

-(void) addHeadAndFooterToTableView
{
    //self.tableView.allowsSelection = NO;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 45.0)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0,self.tableView.frame.size.width-10 , 30)];
    labelView.text = @"ACCOUNT INFO";
    labelView.font = [UIFont fontWithName:KSMuseoSans300 size:14];
    labelView.textColor = [UIColor colorFromHexString:@"#187a89"];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueSettingsToEditUserInfo"]) {
        
        KSAccountEditController *editController = (KSAccountEditController*)[segue destinationViewController];
        
        editController.user = user;
    }
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        
        [self performSegueWithIdentifier:@"segueSettingsToChangePassword" sender:self];
    }
    else {
        //[self performSegueWithIdentifier:@"segueSettingsToPartners" sender:self];
        [self logout];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingActionCellIndentifier"];
    UIImageView *imgView = (UIImageView*) [cell viewWithTag:5001];
    KSLabel *lbl = (KSLabel*) [cell viewWithTag:5002];
    //UIImageView *img = (UIImageView*) [cell viewWithTag:5003];
    [lbl setFont:[UIFont fontWithName:KSMuseoSans500 size:15]];
    [lbl setTextColor:[UIColor colorFromHexString:@"#1e1e1e"]];
    
    if(indexPath.row == 0)
    {
        [imgView setImage:[UIImage imageNamed:@"password.png"]];
        [lbl setText:@"Change Password"];
        //[cell viewWithTag:101].hidden = FALSE;
    }
    else{
        [imgView setImage:[UIImage imageNamed:@"logout-ico-idle.png"]];
        [lbl setText:@"Logout"];
        
        [cell viewWithTag:5003].hidden = TRUE;
    }
    
    return cell;
}

#pragma mark - Logout

-(void) logout
{
    KSConfirmationAlertAction *okAction = [KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
        [self logoutThisUser];
    }];
    
    KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel" handler:^(KSConfirmationAlertAction *action) {
        //[self.revealViewController revealToggleAnimated:YES];
    }];
    [KSConfirmationAlert showWithTitle:nil
                               message:@"Are you sure you want to logout?"
                              okAction:okAction
                          cancelAction:cancelAction];
}

-(void) logoutThisUser
{
    [KSDAL logoutUser];
    [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginScreen];
}

@end
