//
//  KSStoryBoard.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "UIStoryboard+KSStoryBoard.h"

@implementation UIStoryboard (KSStoryBoard)

+ (id)viewControllerWithIdentifier:(NSString *)identifier {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:identifier];
}

+ (id)verifyController {
    return [self viewControllerWithIdentifier:@"KSVerifyController"];
}

+ (id)mainRootController {
    return [self viewControllerWithIdentifier:@"KSMainRootController"];
}

+ (id)loginRootController {
    return [self viewControllerWithIdentifier:@"KSLoginRootController"];
}

+ (id)menuController {
    return [self viewControllerWithIdentifier:@"KSMenuController"];
}

+ (id)bookingDetailsController {
    return [self viewControllerWithIdentifier:@"KSBookingDetailsController"];
}

+ (id)addressPickerController {
    
    return [self viewControllerWithIdentifier:@"KSAddressPickerController"];
}

+ (id)tripRatingController {
    
    return [self viewControllerWithIdentifier:@"KSTripRatingController"];
}

+ (id) bookingMapController {
    
    return [self viewControllerWithIdentifier:@"BookingMapScene"];
}

@end
