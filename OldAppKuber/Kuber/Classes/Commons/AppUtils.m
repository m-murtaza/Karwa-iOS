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


+ (NSString *) vehicleTypeToString:(KSVehicleType)type
{
    NSString *strType = @"";
    switch (type) {
        case KSCityTaxi:
        case KSAiportTaxi:
        case KSAirportSpare:
        case KSAiport7Seater:
        case KSSpecialNeedTaxi:
            strType = @"Taxi";
            break;
        case KSStandardLimo:
            strType = @"Standard Limo";
            break;
        case KSBusinessLimo:
            strType = @"Business Limo";
            break;
        case KSLuxuryLimo:
            strType = @"Luxury Limo";
            break;
        default:
            strType = @"Taxi";
            break;
    }
    return strType;
}


+ (BOOL) isLargeScreen:(UIViewController*)controller
{
    BOOL largeScreen = TRUE;
    NSInteger horizontalClass = controller.traitCollection.horizontalSizeClass;
    switch (horizontalClass) {
        case UIUserInterfaceSizeClassCompact :
            largeScreen = FALSE;
            break;
        case UIUserInterfaceSizeClassRegular :
            largeScreen = TRUE;
            break;
        default :
            largeScreen = FALSE;
            break;
    }
    return largeScreen;
    
}
@end
