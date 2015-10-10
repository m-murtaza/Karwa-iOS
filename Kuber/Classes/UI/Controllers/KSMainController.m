//
//  ViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMainController.h"
#import "KSWebClient.h"
#import "ABManager.h"

@interface KSMainController ()
{

}
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;

@end

@implementation KSMainController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.btnSignIn.titleLabel setFont:[UIFont fontWithName:@"MuseoForDell-500" size:15.0]];
    
    // Sync locations
    [KSDAL syncLocationsWithCompletion:^(KSAPIStatus status, id response) {
        // TODO: Nothing
    }];
    
    
    [[[ABManager alloc] init] fetchUserPhoneNumber];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [KSGoogleAnalytics trackPage:@"Main View Controller"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    }
}

@end
