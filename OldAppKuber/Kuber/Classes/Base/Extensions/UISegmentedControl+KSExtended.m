//
//  UISegmentedControl+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "UISegmentedControl+KSExtended.h"

@implementation UISegmentedControl (KSExtended)

- (void)setBackgroudImage:(UIImage *)backgroundImage
         highlightedImage:(UIImage *)highlightedBackgroundImage
             dividerImage:(UIImage *)dividerImage {

    CGRect frame = self.frame;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, backgroundImage.size.height);
    
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateDisabled
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:highlightedBackgroundImage
                    forState:UIControlStateSelected
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:highlightedBackgroundImage
                    forState:UIControlStateHighlighted
                  barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:dividerImage
      forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateSelected
               barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage
      forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage
      forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    
}

- (void)setTitleColor:(UIColor *)color forControlState:(UIControlState)state {
    
    if (!color) {
        return;
    }
    NSDictionary *oldAttribs = [self titleTextAttributesForState:state];
    NSMutableDictionary *textAttributes;
    textAttributes = oldAttribs ? [NSMutableDictionary dictionaryWithDictionary:oldAttribs] : [NSMutableDictionary dictionary];
    [textAttributes setObject:color forKey:NSForegroundColorAttributeName];
    
    [self setTitleTextAttributes:textAttributes forState:state];

}



@end
