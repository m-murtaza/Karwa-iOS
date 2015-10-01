//
//  NSDate+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 8/16/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSDate+KSExtended.h"

@implementation NSDate (KSExtended)

- (BOOL)isValidDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *minDate = [dateFormatter dateFromString:@"2000-01-01"];
    BOOL isValid = ([minDate compare:self] == NSOrderedAscending);
    return isValid;
}

- (NSString *)dateString {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];

    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateTimeString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy, HH:mm"];

    return [dateFormatter stringFromDate:self];
}

- (NSString *)jsonDateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-ddTHH:mm:ss.SSS"];
    return [dateFormatter stringFromDate:self];
}


-(NSString*) getFormattedTitleDate
{
    NSDateFormatter *formator = [[NSDateFormatter alloc] init];
    [formator setDateFormat:@"EEE d MMM"];
    NSString *str = [formator stringFromDate:self];
    return [str uppercaseString];
}

-(NSString*) getTimeStringFromDate
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    
    NSString *dateString = [timeFormatter stringFromDate:self];
    return dateString;
}

- (NSString*) formatedDateForBooking
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EE d MMM, hh:mm a"];
    
    //Optionally for time zone conversions
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *stringFromDate = [formatter stringFromDate:self];
    return stringFromDate;
}
@end
