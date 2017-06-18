//
//  UINavigationController+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (KSExtended)

- (void)popToNthController:(NSUInteger)numberOfControllers animated:(BOOL)animated;

@end
