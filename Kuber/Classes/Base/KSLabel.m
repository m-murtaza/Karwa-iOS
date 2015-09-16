//
//  KSLabel.m
//  Kuber
//
//  Created by Asif Kamboh on 9/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSLabel.h"

@implementation KSLabel

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.font = [UIFont fontWithName:@"MuseoForDell-300" size:15];
    }
    return self;
}

-(void) setFontSize:(NSInteger)size
{
    self.font = [UIFont fontWithName:@"MuseoForDell-300" size:size];
}

@end
