//
//  KSUIImageViewAnnotation.m
//  Kuber
//
//  Created by Muhammad Usman on 4/27/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "KSUIImageViewAnnotation.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@implementation KSUIImageViewAnnotation

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(nullable KSUIImageViewAnnotation*) initWithImage:(nullable UIImage *)image Bearing:(CGFloat)b
{
    self = [super initWithImage:image];
    if(self != nil)
    {
        //Do some thing if needed
    }
    
    return self;
}
-(void) updateBearing:(CGFloat)bearing Completion:(KSImageAnimationCompletionBlock)completionBlock;
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(bearing));
                         
                     }
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             completionBlock();
                         }
                     }];
    //[UIView commitAnimations];
}

@end
