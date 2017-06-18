//
//  KSTOSController.m
//  Kuber
//
//  Created by Asif Kamboh on 11/15/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSTOSController.h"

#define TOS_URL     @"http://www.karwasolutions.com/tos.htm"


@interface KSTOSController () <UIWebViewDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end


@implementation KSTOSController

-(void) viewDidLoad
{
    [super viewDidLoad];
    //[self loadWebView];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadWebView];
    [KSGoogleAnalytics trackPage:@"Terms of Services"];
    self.navigationItem.title = @"Terms of Services";
}

#pragma mark - Private Functions

-(void) loadWebView
{
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TOS_URL]];
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
