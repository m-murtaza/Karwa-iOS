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
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    NSLog(@"Error %@",error);
}

@end
