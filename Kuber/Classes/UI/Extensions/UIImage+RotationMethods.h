//
//  UIImage+RotationMethods.h
//  Kuber
//
//  Created by Muhammad Usman on 4/26/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RotationMethods)

@property (nonatomic,strong) NSNumber *bearing;

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
