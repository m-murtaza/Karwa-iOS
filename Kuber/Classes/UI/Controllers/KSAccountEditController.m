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
@property (weak, nonatomic) IBOutlet KSTextField *txtMobile;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onClickSave:(id)sender;

@end

@implementation KSAccountEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addHeadAndFooterToTableView];
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

#pragma mark - Private Functions
-(void) addHeadAndFooterToTableView
{
    self.tableView.allowsSelection = NO;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 45.0)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0,self.tableView.frame.size.width-10 , 30)];
    labelView.text = @"ACCOUNT INFO";
    labelView.font = [UIFont fontWithName:@"MuseoForDell-300" size:14];
    labelView.textColor = [UIColor colorFromHexString:@"#187a89"];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - Events
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

#pragma mark - UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"inputCellIdentifier"];
    UIColor *color = [UIColor colorFromHexString:@"#999999"];
    
    if (indexPath.row == 0) {
        
        self.txtMobile = (KSTextField*)[cell viewWithTag:4001];
        self.txtMobile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Mobile number" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtMobile.text = self.user.phone;
        [self.txtMobile setEnabled:FALSE];
        self.txtMobile.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"phonenumber.png"]];
    }
    else if(indexPath.row == 1){
        
        self.txtName = (KSTextField*)[cell viewWithTag:4001];
        self.txtName.text = self.user.name;
        self.txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Display Name" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtName.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"fullname.png"]];
        
    }
    else if (indexPath.row == 2){
        
        self.txtEmail = (KSTextField*)[cell viewWithTag:4001];
        self.txtEmail.text = self.user.email;
        //self.txtEmail.placeholder = @"Email Address";
        self.txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: color}];
        self.txtEmail.tintColor = [UIColor blackColor];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:4002];
        [imgView setImage:[UIImage imageNamed:@"email.png"]];
    }
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
