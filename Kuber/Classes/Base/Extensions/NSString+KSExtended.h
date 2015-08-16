//
//  NSString+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *KSLocalize(NSString *key);

@interface NSString (KSExtended)

+ (NSString *)hexString:(const unsigned char *)buffer length:(NSUInteger)length;

- (BOOL)isEmailAddress;

- (BOOL)isPhoneNumber;

- (NSString *)localizedValue;

- (BOOL)startsWith:(NSString *)str;

- (BOOL)startsWithCaseInsensitive:(NSString *)str;

- (NSDate *)dateValue;

@end

