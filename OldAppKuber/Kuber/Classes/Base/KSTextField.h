//
//  KSTextField.h
//  Kuber
//
//  Created by Asif Kamboh on 9/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTextField : UITextField

@property (nonatomic) NSInteger transformVal;
@property (nonatomic, strong) NSString *focusedImg;
@property (nonatomic, strong) NSString *idleImg;
@property (nonatomic, strong) UIColor *placeholderColor;

@end
