//
//  UIViewController+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "UIViewController+KSExtended.h"
#import "SWRevealViewController.h"

@implementation UIViewController (KSExtended)

- (UIBarButtonItem *)revealButtonItem {
    return nil;
}

#pragma mark -
#pragma mark - RevealViewController setup

- (void)setupRevealViewController {

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController && self.revealButtonItem) {
        if (self.revealButtonItem) {
            [self.revealButtonItem setTarget: revealViewController];
            [self.revealButtonItem setAction: @selector(revealToggle:)];
            [self.navigationController.navigationBar addGestureRecognizer: revealViewController.panGestureRecognizer];
        }
        
    }
}

@end
