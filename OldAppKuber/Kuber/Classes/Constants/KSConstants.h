//
//  KSConstants.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString * const kKSViewWillAppearNotification;
//extern NSString * const kKSViewWillDisappearNotification;

extern NSString * const KSNotificationForNewBookmark;

extern NSString * const KSCountryNameForLocationSearch;

extern NSString * const KSPickerIdForPickupAddress;
extern NSString * const KSPickerIdForDropoffAddress;

extern NSString * const KSBookingTypeCurrent;

extern NSInteger const phoneNumberLength;

extern NSString * const KSTaxiLimoDefaultKey;
extern NSString * const KSLimoTypeDefaultKey;

typedef NS_OPTIONS(NSUInteger, KSAPIStatus) {
    KSAPIStatusUnknownError             = 0,    // Generic Error
    KSAPIStatusSuccess                  = 1,    // Success Case
    KSAPIStatusUserNotRegistered        = 2,    // Mobile number provided doesn't exist in DB
    KSAPIStatusUserAlreadyRegistered    = 3,    // User with given phone number is already registered
    KSAPIStatusWrongAccessCode          = 4,    // Access code sent via SMS doesn't match
    KSAPIStatusInvalidPassword          = 5,    // Passowrd invalid
    KSAPIStatusInvalidSession           = 6,    // Session deleted from server, or request doesn't have sid
    KSAPIStatusUserNotVerified          = 7,
    KSAPIStatusPasswordMatch            = 8,
    KSAPIStatusTooManyResetCalls        = 9,
    KSAPIStatusInvalidPhoneNumber       = 10,
    
    KSAPIStatusTaxiAllocated            = 11,   // Taxi found/allocated
    KSAPIStatusJobAlreadyPending        = 12,   // Already has a pending job
    KSAPIStatusPassengerInTaxi          = 13,   // Job is running  
    KSAPIInvalidPickupLocation          = 14,   // Job is in dispatch queue
    KSAPIStatusBookingCancelled         = 15,   // Job cancelled by user or dispatcher
    KSAPIStatusTaxiNotAvailable         = 16,   // No taxi available sent by dispatcher
    KSAPIStatusInvalidJob               = 17,
    
    KSAPIStatusFavoriteAlreadyExists    = 21,   // Favorite with given name already exists
    KSAPIStatusFavoritesLimitReached    = 22,   // Max limit is 20 for adding bookmarks/favorites
    KSAPIStatusFavoriteDoesNotExist     = 23,   // Favorite given by name does not exisit in DB
    
    KSAPIStatusJobAlreadyRated          = 31,   // Customer has already rated the job
    
    KSAPIStatusInvalidDirver            = 32,   // Driver ID is not is DB
    KSAPIStatusInvalidTaxi              = 33,    // Taxi number is not in DB
    KSAPIStatusNoInternet               = 499,   //No internet available on deviec
    KSAPIStatusBadRequest               = 400,  //Bad Request
    KSAPIStatusSessionExpired           = 401,  //Session Expired
    KSAPIStatusNotFound                 = 404,  //Not found
    KSAPIStatusServerCrash              = 500,  //Server Crash
    KSAPIStatusNotImplemented           = 501,  //Service not implemented
    KSAPIStatusServiceUnavailable       = 503   //Request type not supported i.e. GET, POST
};

typedef NS_OPTIONS(NSUInteger, KSBookingOption) {
    KSBookingOptionInsideCity = 0,
    KSBookingOptionAirport = 1,
    KSBookingOptionOutsideCity = 2
};

typedef NS_OPTIONS(NSUInteger, KSTripStatus) {
    KSTripStatusOpen                = 0,                   //For Advance Job before dispatcher pick up this job and move to current bookings.
    KSTripStatusInProcess           = 1,              //When a job is current or dispatcher moves advance job to current bookings.
    KSTripStatusTaxiAssigned         = 4,            //When Taxi is assigned to some job Automaticly.
    KSTripStatusCancelled           = 7,
    KSTripStatusComplete            = 6,
    KSTripStatusTaxiNotFound        = 9,
    KSTripStatusManuallyAssigned    = 12,
    KSTripStatusPassengerInTaxi     = 5,
    KSTripStatusPending             = 98,
    KSTripStatusCompletedNotRated   = 99
};


typedef NS_OPTIONS(NSUInteger, KSVehicleType) {
    KSCityTaxi                      = 1,
    KSAiport7Seater                 = 3,
    KSAirportSpare                  = 5,
    KSSpecialNeedTaxi               = 10,
    KSAiportTaxi                    = 11,
    //KSCompactLimo                   = 20,
    KSStandardLimo                  = 30,
    KSBusinessLimo                  = 50,
    KSLuxuryLimo                    = 70
};

typedef NS_OPTIONS(NSUInteger, KSCustomerType) {
    KSStandardCustomer             = 1,
    KSVVIPCustomer                 = 2,
    KSVIPCustomer                  = 3,
    KSMowasalatEmpCustomer         = 4,
    KSPriorityCustomer             = 5,
    KSSpecialNeedCustomer          = 6,
    KSJinxedCustomer               = 7,
    KSCorporateCustomer            = 100
};
