//
//  UIUnderlinedButton.m
//  Kuber
//
//  Created by Asif Kamboh on 11/12/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "UIUnderlinedButton.h"

@implementation UIUnderlinedButton

//+ (UIUnderlinedButton*) underlinedButton {
//    UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
    //return [button autorelease];
//}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender+2.5;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width -3, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}
@end
