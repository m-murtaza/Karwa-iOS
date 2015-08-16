//
//  UIStoryboard+KSStoryBoard.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (KSStoryBoard)

+ (id)viewControllerWithIdentifier:(NSString *)identifier;

+ (id)menuController;

+ (id)mainRootController;

+ (id)loginRootController;

+ (id)verifyController;

+ (id)bookingDetailsController;

+ (id)addressPickerController;

+ (id)tripRatingController;

@end
