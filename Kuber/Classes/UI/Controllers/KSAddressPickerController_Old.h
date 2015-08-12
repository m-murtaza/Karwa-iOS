//
//  KSAddressPickerController_Old.h
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTableViewController.h"
#import "KSAddressPickerDelegate.h"


@interface KSAddressPickerController_Old : KSTableViewController

@property (nonatomic, copy) NSString *pickerId;

@property (nonatomic, assign) id<KSAddressPickerDelegate> delegate;

@end
