//
//  UIViewController+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "UIViewController+KSExtended.h"
#import "SWRevealViewController.h"


const NSInteger KSViewControllerTagForLoadingView = 1000000001;

@implementation UIViewController (KSExtended)

- (void)showLoadingView {

    UIView *parentView = self.navigationController ? self.navigationController.view : self.view;
    MBProgressHUD *hud = (MBProgressHUD *)[parentView viewWithTag:KSViewControllerTagForLoadingView];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
        hud.tag = KSViewControllerTagForLoadingView;
    }
}

- (void)hideLoadingView {
    UIView *parentView = self.navigationController ? self.navigationController.view : self.view;
    MBProgressHUD *hud = (MBProgressHUD *)[parentView viewWithTag:KSViewControllerTagForLoadingView];
    [hud hide:YES];
}

#pragma mark -
#pragma mark - RevealViewController setup

- (UIBarButtonItem *)revealButtonItem {
    return nil;
}

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
