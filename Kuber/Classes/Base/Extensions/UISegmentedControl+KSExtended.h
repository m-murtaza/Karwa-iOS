//
//  UISegmentedControl+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (KSExtended)

- (void)setBackgroudImage:(UIImage *)backgroundImage
         highlightedImage:(UIImage *)highlightedBackgroundImage
             dividerImage:(UIImage *)dividerImage;

- (void)setTitleColor:(UIColor *)color forControlState:(UIControlState)state;

@end
