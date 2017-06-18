//
//  UIImage+RotationMethods.m
//  Kuber
//
//  Created by Muhammad Usman on 4/26/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "UIImage+RotationMethods.h"
#import <objc/runtime.h>

static void * BearingPropertyKey = &BearingPropertyKey;

@implementation UIImage (RotationMethods)

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};


- (NSNumber*)bearing {
    return objc_getAssociatedObject(self, BearingPropertyKey);
}

- (void)setBearing:(NSNumber*)bearing {
    objc_setAssociatedObject(self, BearingPropertyKey, bearing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(CGFloat) calculateUpdatedBearing:(CGFloat)degree
{
    CGFloat oldBearing;
    if(self.bearing != nil)
        oldBearing = [self.bearing floatValue];         //Suppose old angle was 45 degree (self.bearing) i.e. image was already rotated to 45 degree. New value is 60 degree (degree)
    else
        oldBearing = 0;
    
    CGFloat updatedBearing = degree - oldBearing;   //60 -45 =15, Image need to be rotated 15 degree.
    
    self.bearing = [NSNumber numberWithFloat:degree];
    return updatedBearing;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    
    degrees = [self calculateUpdatedBearing:degrees];
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    //UIGraphicsBeginImageContext(rotatedSize); // For iOS < 4.0
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 0.0);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    newImage.bearing = self.bearing;
    UIGraphicsEndImageContext();
    return newImage;
}

@end
