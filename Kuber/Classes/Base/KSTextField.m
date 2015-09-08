//
//  KSTextField.m
//  Kuber
//
//  Created by Asif Kamboh on 9/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTextField.h"

@implementation KSTextField

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //UIColor *color = [UIColor colorWithRed:123.0/256.0 green:169.0/256.0 blue:178.0/256.0 alpha:1.0];
        //self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color}];
        self.font = [UIFont fontWithName:@"MuseoForDell-300" size:15.0];
        self.tintColor = [UIColor whiteColor];
        
    }
    return self;
}

@end
