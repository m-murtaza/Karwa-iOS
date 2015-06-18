//
//  KSAppStrings.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KSErrorPhoneValidation;
extern NSString * const KSErrorNoPassword;

extern NSString * const KSErrorNoUserName;
extern NSString * const KSErrorEmailValidation;
extern NSString * const KSErrorPasswordsMismatch;

extern NSString * const KSErrorNoNewPassword;
extern NSString * const KSErrorPasswordsMatch;

extern NSString * const KSAlertTitleError;
extern NSString * const KSAlertTitleMultipleErrors;

extern NSString * const KSTableViewDefaultErrorMessage;

NSString *KSStringFromAPIStatus(KSAPIStatus status);
