//
//  KSAlert.h
//  Kuber
//
//  Created by Asif Kamboh on 5/18/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSAlert : NSObject

+ (void)show:(NSString *)message;
+ (void)show:(NSString *)message title:(NSString *)title;
+ (void)show:(NSString *)message title:(NSString *)title btnTitle:(NSString *)btnTitle;

@end
