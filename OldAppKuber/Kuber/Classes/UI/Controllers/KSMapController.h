//
//  KSMapController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

#import "KSDatePicker.h"


@interface KSMapController : KSViewController<UITextFieldDelegate,KSDatePickerDelegate>

@property (nonatomic) KSBookingOption bookingOption;

@end

