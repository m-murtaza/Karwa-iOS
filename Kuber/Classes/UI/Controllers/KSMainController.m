//
//  ViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMainController.h"
#import "KSWebClient.h"

@interface KSMainController ()
{
    KSWebClientXMLResponseParser *_xmlParser;
}

@end

@implementation KSMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(testRequest) withObject:nil afterDelay:1.];
}

- (void)testRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // mobileno=0556470689&lat=25.345678&lon=54.23456
    params[@"phone"] = @"0556470689";
    params[@"lat"] = [NSNumber numberWithDouble:25.345678];
    params[@"lon"] = [NSNumber numberWithDouble:54.23456];

    [[KSWebClient instance] POST:@"/register" data:params completion:^(BOOL success, id response) {
        NSLog(@"Request %@", success ? @"PASSED" : @"FAILED");
        NSLog(@"%@", response);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
