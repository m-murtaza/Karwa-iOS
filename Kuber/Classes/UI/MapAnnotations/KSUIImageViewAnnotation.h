//
//  KSUIImageViewAnnotation.h
//  Kuber
//
//  Created by Muhammad Usman on 4/27/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KSImageAnimationCompletionBlock)();

@interface KSUIImageViewAnnotation : UIImageView

//@property (nonatomic) CGFloat bearing;

-(nullable KSUIImageViewAnnotation*) initWithImage:(nullable UIImage *)image Bearing:(CGFloat)b;

-(void) updateBearing:(CGFloat)bearing Completion:(nullable KSImageAnimationCompletionBlock)completionBlock;

@end
