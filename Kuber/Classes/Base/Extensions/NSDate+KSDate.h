//
//  NSDate+KSDate.h
//  Kuber
//
//  Created by Asif Kamboh on 9/7/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KSDate)

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
+ (NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate;
+(NSString*) bookingHistoryDateToString:(NSDate*)date;



@end
