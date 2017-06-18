//  CLPlacemark+Extended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (KSExtended)

- (NSString *)address;

- (NSString *)fullAddress;

- (NSString *)addressWithoutName;

@end

