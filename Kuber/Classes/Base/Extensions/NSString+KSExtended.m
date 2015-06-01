//
//  MD5.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSString+KSExtended.h"

NSString *KSLocalize(NSString *key) {
    return NSLocalizedString(key, nil);
}

@implementation NSString (KSExtended)

+ (NSString *)hexString:(const unsigned char *)buffer length:(NSUInteger)length {
    NSMutableString *hexString = [NSMutableString stringWithCapacity:length * 2];
    for (int i = 0; i < length; i++) {
        [hexString appendFormat:@"%02x",buffer[i]];
    }
    return hexString;
}

- (BOOL)isValidForPattern:(NSString *)regExPattern {
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return (regExMatches > 0);
}

- (BOOL)isEmailAddress {
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self isValidForPattern:regExPattern];
}

- (BOOL)isPhoneNumber {
    NSString *regExPattern = @"^[\\+\\d](?:[0-9]●?){4,14}[0-9]$";
    return [self isValidForPattern:regExPattern];
}

- (NSString *)localizedValue {
    return KSLocalize(self);
}

- (BOOL)startsWith:(NSString *)str {
    return ![self rangeOfString:str].location;
}

- (BOOL)startsWithCaseInsensitive:(NSString *)str {
    return ![self rangeOfString:str options:NSCaseInsensitiveSearch].location;
}

@end

