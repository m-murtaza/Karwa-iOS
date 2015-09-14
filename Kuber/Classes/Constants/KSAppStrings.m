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

NSString * const KSErrorNoUserName = @"Please enter your name";
NSString * const KSErrorEmailValidation = @"Please provide a valid email address";
NSString * const KSErrorPasswordsMismatch = @"Passwords do not match";

NSString * const KSAlertTitleError = @"Error";
NSString * const KSAlertTitleMultipleErrors = @"Multiple Errors";

NSString * const KSErrorNoNewPassword = @"Please enter new password";
NSString * const KSErrorPasswordsMatch = @"Current and new passwords can not be same";

NSString * const KSTableViewDefaultErrorMessage = @"No Data Available";

NSString *KSStringFromAPIStatus(KSAPIStatus status) {
    NSDictionary *stringsForAPIStatus =
    @{
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUnknownError]:             @"We are experiencing technical difficulties, please stand by",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusSuccess]:                  @"Request completed successfully",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotRegistered]:        @"Phone number is not registered with Karwa",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserAlreadyRegistered]:    @"This phone number is already registered with Karwa",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusWrongAccessCode]:          @"Please enter a valid access code",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidPassword]:          @"Invalid phone number or password",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidSession]:           @"Your session is expired, please login again",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotVerified]:          @"Unverified phone number, please enter verification code",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPasswordMatch]:            @"Current and new passwords can not be same",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTooManyResetCalls]:        @"Please contact our customer service to reset your password",
      
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiAllocated]:            @"Taxi allocated for you --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyPending]:        @"You already have pending bookings for same time period",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPassengerInTaxi]:          @"Aren't you in Taxi? --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusBookingCancelled]:         @"You have cancelled the booking --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiNotAvailable]:         @"Dear Customer, we are fully booked, Please try different pick up time",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteAlreadyExists]:    @"A favorite with the given name already exists, please select different name",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoritesLimitReached]:    @"To add new favorite, please remove some favorite places",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteDoesNotExist]:     @"You have deleted this place as favorite",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyRated]:          @"You have already rated this trip",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidDirver]:            @"This driver is no more with us--",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidTaxi]:              @"This taxi is not in our database--",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusNoInternet]:               @"Internet not available please check your internet settings",
    };

    NSString *string =  [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: status]];

    if (!string) {
        string = [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: KSAPIStatusUnknownError]];
    }

    return string;
}
