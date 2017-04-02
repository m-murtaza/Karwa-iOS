//
//  AppUtils.h
//  Kuber
//
//  Created by Muhammad Usman on 4/2/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

+ (BOOL) isTaxiType:(KSVehicleType) type;

+ (NSString *) taxiLimoText:(KSVehicleType) type;
+ (NSString *) taxiLimo:(NSNumber *) type;
@end
