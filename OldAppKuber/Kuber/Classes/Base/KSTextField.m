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
        self.font = [UIFont fontWithName:KSMuseoSans300 size:15.0];
        self.tintColor = [UIColor whiteColor];
        [self setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        
    }
    return self;
}

/*- (void)setText:(NSString *)text {
    
    [super setText:text];
}*/

- (void) drawPlaceholderInRect:(CGRect)rect
{
    if (!self.placeholderColor) {
        self.placeholderColor = [UIColor colorWithRed:123.0/256.0 green:169.0/256.0 blue:178.0/256.0 alpha:1.0];
    }
    
    
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);
    
    UIFont *font = [UIFont fontWithName:self.font.fontName size:15.0];
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : self.placeholderColor,
                                 NSFontAttributeName : font
                                 };
    

    [[self placeholder] drawInRect:placeholderRect withAttributes:attributes];
}
@end
