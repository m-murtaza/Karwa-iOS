//
//  KSViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "SWRevealViewController.h"

#import "KSViewController.h"

@interface KSViewController () 


@end

@implementation KSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    //[self setupRevealViewController];
    
    //set Back button title
    //Use UIBarButtonItemStylePlain
    /*UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@""
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    [self.navigationItem setBackBarButtonItem: btnBack];*/
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


-(void) APICallFailAction:(KSAPIStatus) status
{
    if(status == KSAPIStatusInvalidSession || status == KSAPIStatusSessionExpired)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:KSStringFromAPIStatus(status)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              
                                                                  [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginScreen];
                                                              }];
        
        [alert addAction:defaultAction];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [KSAlert show:KSStringFromAPIStatus(status)];
    }
}

#pragma mark - Restoration
- (void)applicationFinishedRestoringState {
    
}

#pragma mark -
- (BOOL)isOnScreen {
    return [self isViewLoaded] && self.view.window;
}


@end
