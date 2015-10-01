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

NSString * const KSMuseoSans300 = @"MuseoSans_300";
NSString * const KSMuseoSans500 = @"MuseoSans_500";
NSString * const KSMuseoSans700 = @"MuseoSans_700";


NSString *KSStringFromAPIStatus(KSAPIStatus status) {
    NSDictionary *stringsForAPIStatus =
    @{
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUnknownError]:             @"We are experiencing technical difficulties, please stand by",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusSuccess]:                  @"Request completed successfully",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotRegistered]:        @"Phone number is not registered.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserAlreadyRegistered]:    @"This phone number is already registered.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusWrongAccessCode]:          @"Please enter a valid verification code",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidPassword]:          @"Invalid phone number or password",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidSession]:           @"Your session has expired. Please login again.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusUserNotVerified]:          @"Phone number is not verified. Please verify phone number using verification code.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPasswordMatch]:            @"New password is same old password.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTooManyResetCalls]:        @"You have exceed maximum number of reset requests. Please send an email to ualeem@karwasolutions.com to reset your password",
      
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiAllocated]:            @"Taxi allocated for you --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyPending]:        @"You have another booking in process. Please select a different booking time.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusPassengerInTaxi]:          @"Aren't you in Taxi? --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusBookingCancelled]:         @"You have cancelled the booking --",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusTaxiNotAvailable]:         @"We are unable to book a taxi for the given time. Please try again for a different time.",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteAlreadyExists]:    @"Favorite name already exists, please try a different name",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoritesLimitReached]:    @"You have reach maximum number of favorites.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusFavoriteDoesNotExist]:     @"Favorite has already removed from your account.",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusJobAlreadyRated]:          @"You have already rated this trip",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidDirver]:            @"This driver is no more with us--",

      [NSNumber numberWithUnsignedInteger:KSAPIStatusInvalidTaxi]:              @"This taxi is not in our database--",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusNoInternet]:               @"Unable to access interet. Please check network settings",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusBadRequest]:               @"Oops…. Something went wrong. Please try again later",
      
      [NSNumber numberWithUnsignedInteger:KSAPIStatusSessionExpired]:           @"Your session has expired, Please login again.",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusNotFound]:                 @"Oops…. Something went wrong. Please try again later",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusServerCrash]:              @"Oops…. Something went wrong. Please try again later",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusNotImplemented]:           @"Oops…. Something went wrong. Please try again later",
      [NSNumber numberWithUnsignedInteger:KSAPIStatusServiceUnavailable]:       @"Oops…. Something went wrong. Please try again later",
      
    };
    
    /*KSAPIStatusNoInternet               = 499,   //No internet available on deviec
     KSAPIStatusBadRequest               = 400,  //Bad Request
     KSAPIStatusSessionExpired           = 401,  //Session Expired
     KSAPIStatusNotFound                 = 404,  //Not found
     KSAPIStatusServerCrash              = 500,  //Server Crash
     KSAPIStatusNotImplemented           = 501,  //Service not implemented
     KSAPIStatusServiceUnavailable       = 503   //Request type not supported i.e. GET, POST*/

    NSString *string =  [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: status]];

    if (!string) {
        string = [stringsForAPIStatus objectForKey:[NSNumber numberWithUnsignedInteger: KSAPIStatusUnknownError]];
    }

    return string;
}
