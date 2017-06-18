//
//  NSString+MD5.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+NSData+MD5.h"

#import "NSString+KSExtended.h"

@implementation NSString (MD5)

- (NSString *)MD5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    return [NSString hexString:md5Buffer length:CC_MD5_DIGEST_LENGTH];
}

@end

@implementation NSData (MD5)

- (NSString *)MD5 {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    return [NSString hexString:md5Buffer length:CC_MD5_DIGEST_LENGTH];
}

@end

