//
//  KSBookingConfirmationController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/3/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

@class KSAddress;

@interface KSBookingConfirmationController : KSViewController


@property (nonatomic, strong) KSAddress *pickupAddress;
@property (nonatomic, strong) KSAddress *dropoffAddress;

@property (nonatomic) BOOL showsDatePicker;

@end
