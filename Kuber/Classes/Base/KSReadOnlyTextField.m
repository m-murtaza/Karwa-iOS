//
//  KSReadOnlyTextField.m
//  Kuber
//
//  Created by Asif Kamboh on 5/27/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSReadOnlyTextField.h"

@implementation KSReadOnlyTextField

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (BOOL)becomeFirstResponder {
    [self sendActionsForControlEvents: UIControlEventTouchUpInside];
    return NO;
}

@end
