//
//  KSAddressPickerController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/27/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTableViewController.h"

extern NSString * const KSPickerIdForPickupAddress;
extern NSString * const KSPickerIdForDropoffAddress;

@class CLLocation;
@class CLPlacemark;

@protocol KSAddressPickerDelegate;

@interface KSAddressPickerController : UITableViewController

@property (nonatomic, copy) NSString *pickerId;

@property (nonatomic, assign) id<KSAddressPickerDelegate> delegate;

@end

@protocol KSAddressPickerDelegate <NSObject>

@required

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location;

@end