//
//  CLPlacemark+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "CLPlacemark+KSExtended.h"

@implementation CLPlacemark (KSExtended)


- (NSString *)addressWithCountry:(BOOL)appendCountryName useName:(BOOL)useName {

    NSMutableArray *addressLines = [NSMutableArray arrayWithArray: self.addressDictionary[@"FormattedAddressLines"]];
    if (!appendCountryName) {
        [addressLines removeLastObject];
    }
    
    NSString *placeName = self.addressDictionary[@"Name"];
    BOOL hasNameLine = [addressLines.firstObject isEqualToString:placeName];
    if (useName && !hasNameLine) {

        if (placeName.length) {
            
            [addressLines insertObject:placeName atIndex:0];
        }
    }
    else if (!useName && hasNameLine) {

        [addressLines removeObjectAtIndex:0];
    }

    return [addressLines componentsJoinedByString:@", "];
}

- (NSString *)address {
    return [self addressWithCountry:NO useName:YES];
}

- (NSString *)fullAddress {
    return [self addressWithCountry:YES useName:YES];
}

- (NSString *)addressWithoutName {
    return [self addressWithCountry:NO useName:NO];
}

@end

