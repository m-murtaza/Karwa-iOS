//
//  KSVehicleTrackingInfo.h
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSVehicleTrackingInfo : NSObject

@property (nonatomic, readonly) NSString *vehicleId;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) double speed;

@property (nonatomic, readonly) NSInteger status;

@property (nonatomic, readonly) NSDate *trackingTime;

@property (nonatomic, readonly) NSInteger driverId;

@property (nonatomic, readonly) NSString *driverName;

@property (nonatomic, readonly) NSString *driverPhone;

+ (instancetype)trackInfoWithDictionary:(NSDictionary *)trackingInfo;

- (instancetype)initWithDictionary:(NSDictionary *)trackingInfo;

@end
