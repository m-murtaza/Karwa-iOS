//
//  KSMenuController.m
//  Kuber
//
//  Created by Asif Kamboh on 8/9/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMenuController.h"

#import "SWRevealViewController.h"
#import "KSConfirmationAlert.h"

@interface KSMenuController ()

@property (nonatomic,weak ) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet UILabel *lblPhone;

- (IBAction)onClickLogout:(id)sender;

@end

@implementation KSMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KSSessionInfo *userSession = [KSSessionInfo currentSession];
    
    KSUser *user = [KSDAL userWithPhone:userSession.phone];
    self.lblDisplayName.text = user.name;
    self.lblPhone.text = user.phone;
}


-(void) viewWillAppear:(BOOL)animated
{
    KSUser *user = [KSDAL loggedInUser];
    self.lblDisplayName.text = [user name];
    [KSGoogleAnalytics trackPage:@"Menu"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Storyboard events

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}

#pragma mark -
#pragma mark - Event handlers

- (void)onClickLogout:(id)sender {
    
    KSConfirmationAlertAction *okAction = [KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
        NSLog(@"%s OK Handler", __PRETTY_FUNCTION__);
        [self logoutThisUser];
    }];
    KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel" handler:^(KSConfirmationAlertAction *action) {
        NSLog(@"%s Cancel Handler", __PRETTY_FUNCTION__);
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    }];
    [KSConfirmationAlert showWithTitle:nil
                               message:@"Cofirm Logout?"
                              okAction:okAction
                          cancelAction:cancelAction];
}

#pragma mark -
#pragma mark - Helper methods

- (void)logoutThisUser {

    [KSDAL logoutUser];
    
    UIViewController *controller = [UIStoryboard loginRootController];
    [self.revealViewController setFrontViewController:controller animated:YES];
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

@end
