//
//  NSDate+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 8/16/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KSExtended)

- (BOOL)isValidDate;

- (NSString *)dateString;

- (NSString *)dateTimeString;

- (NSString *)jsonDateString;

- (NSString*) getFormattedTitleDate;

- (NSString*) getTimeStringFromDate;

- (NSString*) formatedDateForBooking;
- (NSString*) formatedDateForTaxiTracking;
@end
