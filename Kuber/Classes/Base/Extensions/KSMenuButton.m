//
//  KSMenuButton.m
//  Kuber
//
//  Created by Asif Kamboh on 9/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMenuButton.h"

@implementation KSMenuButton

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        [[self titleLabel] setFont:[UIFont fontWithName:@"MuseoForDell-500" size:16]];
        //[self setTitleEdgeInsets:UIEdgeInsetsMake(10.0f, 70.0f, 0.0f, 0.0f)];
        //self.contentHorizontalAlignment = 10;
    
    
    }
    return self;
}


@end
