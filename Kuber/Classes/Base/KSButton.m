//
//  KSButton.m
//  Kuber
//
//  Created by Asif Kamboh on 9/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSButton.h"

@implementation KSButton

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        [[self titleLabel] setFont:[UIFont fontWithName:KSMuseoSans500 size:15]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

@end
