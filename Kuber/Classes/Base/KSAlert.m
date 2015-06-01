//
//  KSAlert.m
//  Kuber
//
//  Created by Asif Kamboh on 5/18/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAlert.h"

@implementation KSAlert

+ (void)show:(NSString *)message title:(NSString *)title btnTitle:(NSString *)btnTitle {
    btnTitle = btnTitle.length ? btnTitle : @"OK";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title.localizedValue
                                                        message:message.localizedValue
                                                       delegate:nil
                                              cancelButtonTitle:btnTitle.localizedValue
                                              otherButtonTitles:nil];
    [alertView show];
    
}

+ (void)show:(NSString *)message title:(NSString *)title {
    [self show:message title:title btnTitle:nil];
}

+ (void)show:(NSString *)message {
    [self show:message title:nil btnTitle:nil];
}

@end
