//
//  KSAddressPickerController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/27/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

#import "KSAddressPickerDelegate.h"


@interface KSAddressPickerController : KSViewController

@property (nonatomic, copy) NSString *pickerId;

@property (nonatomic, assign) id<KSAddressPickerDelegate> delegate;

@end

