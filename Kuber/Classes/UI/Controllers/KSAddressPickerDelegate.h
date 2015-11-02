//
//  KSAddressPickerDelegate.h
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#ifndef Kuber_KSAddressPickerDelegate_h
#define Kuber_KSAddressPickerDelegate_h

#import <Foundation/Foundation.h>

@class KSAddressPickerController;
@class CLLocation;

@protocol KSAddressPickerDelegate <NSObject>

@required

- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location;
- (void)addressPicker:(KSAddressPickerController *)picker didDismissWithAddress:(NSString *)address location:(CLLocation *)location hint:(NSString*)hint;

@end

#endif
