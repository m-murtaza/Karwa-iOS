//
//  ViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMainController.h"
#import "KSWebClient.h"
#import "KSDAL.h"


@interface KSMainController ()
{

}

@end

@implementation KSMainController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Sync locations
    [KSDAL syncLocationsWithCompletion:^(KSAPIStatus status, id response) {
        // TODO: Nothing
    }];
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
