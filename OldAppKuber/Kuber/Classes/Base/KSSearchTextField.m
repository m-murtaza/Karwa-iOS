//
//  KSSearchTextField.m
//  Kuber
//
//  Created by Asif Kamboh on 10/4/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSSearchTextField.h"

@implementation KSSearchTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    //return CGRectMake(35.0,3.0,bounds.size.width,bounds.size.height);//Return your desired x,y position and width,height
    return CGRectMake(35.0,0.0,bounds.size.width,bounds.size.height);
}

/*- (void)drawPlaceholderInRect:(CGRect)rect {
    //draw place holder.
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:12]];
    
}*/
@end
