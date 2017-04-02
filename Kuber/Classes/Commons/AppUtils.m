//
//  AppUtils.m
//  Kuber
//
//  Created by Muhammad Usman on 4/2/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import "AppUtils.h"

@implementation AppUtils

+ (BOOL) isTaxiType:(KSVehicleType) type
{
    BOOL isTaxi = true;
    switch (type) {
        case KSLuxuryLimo:
        case KSBusinessLimo:
        case KSStandardLimo:
        case KSCompactLimo:
            isTaxi = false;
            break;
        case KSCityTaxi:
        case KSAiportTaxi:
        case KSAirportSpare:
        case KSAiport7Seater:
        case KSSpecialNeedTaxi:
        default:
            isTaxi = true;
            break;
    }
    
    return isTaxi;
}

+ (NSString *) taxiLimoText:(KSVehicleType) type
{
    return [AppUtils isTaxiType:type] ? @"Taxi" : @"Limo";
}

+ (NSString *) taxiLimo:(NSNumber *) type
{
    return [AppUtils taxiLimoText: (KSVehicleType)[type integerValue]];
}

@end
