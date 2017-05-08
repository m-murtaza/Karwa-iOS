//
//  KSFareViewController.m
//  Kuber
//
//  Created by Muhammad Usman on 5/8/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSFareViewController.h"

#define Fare_URL     @"http://www.karwatechnologies.com/fare.htm"

@interface KSFareViewController () <UIWebViewDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation KSFareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadWebView];
    [KSGoogleAnalytics trackPage:@"Fare"];
    self.navigationItem.title = @"Fare";
}

#pragma mark - Private Functions

-(void) loadWebView
{
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:Fare_URL]];
    [self.webView loadRequest:request];
}


#pragma mark - Webview Delegate function

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    [hud hide:YES];
}
@end
