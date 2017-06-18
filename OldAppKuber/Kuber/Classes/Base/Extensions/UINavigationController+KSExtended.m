//
//  UINavigationController+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "UINavigationController+KSExtended.h"

@implementation UINavigationController (KSExtended)

- (void)popToNthController:(NSUInteger)numberOfControllers animated:(BOOL)animated {
    NSUInteger maxToPop = self.viewControllers.count - 1;
    if (numberOfControllers == 1) {
        [self popViewControllerAnimated: animated];
    }
    else if (numberOfControllers >= maxToPop) {
        [self popToRootViewControllerAnimated:animated];
    }
    else {
        NSUInteger targetIndex = maxToPop - numberOfControllers;
        UIViewController *targetViewController = [self.viewControllers objectAtIndex:targetIndex];
        [self popToViewController:targetViewController animated:animated];
    }
}

@end
