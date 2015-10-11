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
#import "KSLocationManager.h"

@interface KSMainController () <CLLocationManagerDelegate>
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
    
    
    [self askForLocationAccess];
    
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
    [KSLocationManager stop];
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

-(void) askForLocationAccess
{
    /*CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];*/
    [KSLocationManager start];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
    [manager stopUpdatingLocation];
}
@end
