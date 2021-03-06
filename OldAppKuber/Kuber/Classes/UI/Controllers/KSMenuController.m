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
#import "KSBookingHistoryController.h"
#import "KSTOSController.h"
#import "KSMenuButton.h"

@interface KSMenuController ()

@property (nonatomic,weak ) IBOutlet UILabel *lblDisplayName;
@property (nonatomic, weak) IBOutlet UILabel *lblPhone;
@property (nonatomic, weak) NSArray *btnArray;

@property (nonatomic, weak) IBOutlet KSMenuButton *btnBookATaxi;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintTopSpace;


- (IBAction)onClickLogout:(id)sender;

@end

@implementation KSMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KSSessionInfo *userSession = [KSSessionInfo currentSession];
    
    KSUser *user = [KSDAL userWithPhone:userSession.phone];
    self.lblDisplayName.text = [user.name uppercaseString];
    self.lblDisplayName.font = [UIFont fontWithName:KSMuseoSans500 size:17];
    self.lblPhone.text = user.phone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBookingSelected)
                                                 name:@"KSSetBookingSelected"
                                               object:nil];
    
    
    if(IS_IPHONE_5)
        _constraintTopSpace.constant = 50;
}


-(void) viewWillAppear:(BOOL)animated
{
    NSArray *arr = self.btnBookATaxi.superview.subviews;
    BOOL notSeleted = TRUE;
    
    for (id btn in arr) {
        if ([btn isKindOfClass:[UIButton class]] ) {
            KSMenuButton *b = (KSMenuButton*)btn;
            if (b.state == UIControlStateSelected) {
                notSeleted = false;
                break;
            }
        }
    }
    if (notSeleted) {
        [self.btnBookATaxi setSelected:TRUE];
    }
    
    KSUser *user = [KSDAL loggedInUser];
    self.lblDisplayName.text = [[user name] uppercaseString];
    self.lblPhone.text = user.phone;
    [KSGoogleAnalytics trackPage:@"Menu"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setButtonState:(KSMenuButton*)sender
{
    NSArray *arr = sender.superview.subviews;
    for (id btn in arr) {
        if ([btn isKindOfClass:[UIButton class]]) {
         
            [btn setSelected:FALSE];
        }
    }
    [sender setSelected:TRUE];
}

-(void) enableIntraction
{
    self.view.userInteractionEnabled = TRUE;
}

-(void) setBookingSelected
{
    [self deSelectAll];
    [self.btnBookATaxi setSelected:TRUE];
}

-(void) deSelectAll{

    NSArray *arr = self.btnBookATaxi.superview.subviews;
    
    
    for (id btn in arr) {
        if ([btn isKindOfClass:[UIButton class]] ) {
            KSMenuButton *b = (KSMenuButton*)btn;
            [b setSelected:FALSE];
        }
    }

}

#pragma mark -
#pragma mark - Storyboard events

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //Patch: Did not allow to multiple tap on single button to load a view multiple times. 
    self.view.userInteractionEnabled = FALSE;
    [self performSelector:@selector(enableIntraction)
               withObject:nil
               afterDelay:0.5];
    [self setButtonState:sender];
    
    if ([segue.identifier isEqualToString:@"segueMenuToPendingBookings"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        KSBookingHistoryController * pendingBookings = [navController.viewControllers firstObject];
        pendingBookings.tripStatus = KSTripStatusPending;
        
    }
    else if([segue.identifier isEqualToString:@"segueMenuToRateTrips"]){
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        KSBookingHistoryController * pendingBookings = [navController.viewControllers firstObject];
        pendingBookings.tripStatus = KSTripStatusCompletedNotRated;
    }
//    else if ([segue.identifier isEqualToString:@"SegueMenuFareToTOS"])
//    {
//        UINavigationController *navController = (UINavigationController*) segue.destinationViewController;
//        
//        
//        KSTOSController *tosView = (KSTOSController*) [navController.viewControllers firstObject];
//        
//    }
}

//#pragma mark -
//#pragma mark - Event handlers

//- (void)onClickLogout:(id)sender {
//    
//    KSConfirmationAlertAction *okAction = [KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
//        [self setButtonState:sender];
//        KSMenuButton *btn = (KSMenuButton*)sender;
//        [btn setSelected:FALSE];
//        [self logoutThisUser];
//        
//        /*NSArray *arr = self.btnBookATaxi.superview.subviews;
//        
//        
//        for (id btn in arr) {
//            if ([btn isKindOfClass:[UIButton class]] ) {
//                KSMenuButton *b = (KSMenuButton*)btn;
//                [b setSelected:FALSE];
//            }
//        }*/
//        [self deSelectAll];
//    }];
//    
//    KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel" handler:^(KSConfirmationAlertAction *action) {
//        [self.revealViewController revealToggleAnimated:YES];
//    }];
//    [KSConfirmationAlert showWithTitle:nil
//                               message:@"Are you sure you want to logout?"
//                              okAction:okAction
//                          cancelAction:cancelAction];
//}
//
//#pragma mark -
//#pragma mark - Helper methods
//
//- (void)logoutThisUser {
//
//    [KSDAL logoutUser];
//    UIViewController *controller = [UIStoryboard loginRootController];
//    [self.revealViewController setFrontViewController:controller animated:YES];
//    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
//    
//}

@end
