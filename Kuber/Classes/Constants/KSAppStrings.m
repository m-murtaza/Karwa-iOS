//
//  KSAppStrings.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAppStrings.h"

// Login and regsitration pages
NSString * const KSErrorPhoneValidation = @"Please enter a valid Mobile number";
NSString * const KSErrorNoPassword = @"Password is mandatory";

NSString * const KSErrorNoUserName = @"No user name";
NSString * const KSErrorEmailValidation = @"Email address is not valid";
NSString * const KSErrorPasswordsMismatch = @"Passwords do not match";

NSString * const KSAlertTitleError = @"Error";
NSString * const KSAlertTitleMultipleErrors = @"Multiple Errors";

NSString * const KSErrorNoNewPassword = @"New password is mandatory";
NSString * const KSErrorPasswordsMatch = @"Current and new passwords are same";

NSString * const KSTableViewDefaultErrorMessage = @"No Data Available";

NSString *KSStringFromAPIStatus(KSAPIStatus status) {
    NSDictionary *stringsForAPIStatus =
    @{
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUnknownError]:             @"Some internal error",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusSuccess]:                  @"Request completed successfully",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotRegistered]:        @"Phone number is not registered",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserAlreadyRegistered]:    @"User with given number is already registered",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusWrongAccessCode]:          @"Please enter a valid access code",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidPassword]:          @"Invalid phone number OR password",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidSession]:           @"You session is expired, please login again",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotVerified]:          @"Please verify your phone number",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPasswordMatch]:            @"New and old passwords are same",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTooManyResetCalls]:        @"We have received too many password reset calls",
      
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiAllocated]:            @"Taxi allocated for you",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyPending]:        @"You already have a current booking",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPassengerInTaxi]:          @"Aren't you in Taxi?",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusBookingCancelled]:         @"You have cancelled the booking",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiNotAvailable]:         @"We are sorry, right now all taxi cars are with passengers",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteAlreadyExists]:    @"A favorite with the given name already exists",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoritesLimitReached]:    @"Limit reached. To add new places, please remove some favorite places",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteDoesNotExist]:     @"You don't have such place marked as favorite",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyRated]:          @"You have already rated this job",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidDirver]:            @"This driver is no more with us",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidTaxi]:              @"This taxi is not in our database",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusNoInternet]:               @"Internet not available",
    };

    NSString *string =  [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: status]];

    if (!string) {
        string = [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: KSAPIStatusUnknownError]];
    }

    return string;
}
