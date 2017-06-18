//
//  NSDate+KSDate.m
//  Kuber
//
//  Created by Asif Kamboh on 9/7/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSDate+KSDate.h"

#define SERVER_DATE_FORMAT      @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define DEFAULT_LOCALE          @"en_US"

@implementation NSDate (KSDate)

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

+ (NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate
{
    // Use the user's current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setYear:numberOfYears];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    return newDate;
}

+(NSString*) bookingHistoryDateToString:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}


- (NSString*) bookingDateServerFormat
{
    NSString *strServerFormat = @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:SERVER_DATE_FORMAT];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:DEFAULT_LOCALE]];
    strServerFormat = [dateFormat stringFromDate:self];
    return strServerFormat;
    
}

@end
