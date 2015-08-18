//
//  KSVehicleTrackingInfo.m
//  Kuber
//
//  Created by Asif Kamboh on 8/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSVehicleTrackingInfo.h"

@implementation KSVehicleTrackingInfo

+ (instancetype)trackInfoWithDictionary:(NSDictionary *)trackingInfo {

    return [[self alloc] initWithDictionary:trackingInfo];
}

- (instancetype)initWithDictionary:(NSDictionary *)trackingInfo {

    self = [super init];
    if (self) {
        _coordinate = CLLocationCoordinate2DMake([trackingInfo[@"Lat"] doubleValue], [trackingInfo[@"Lon"] doubleValue]);
        
        _vehicleId = trackingInfo[@"TaxiNo"];
        
        _status = [trackingInfo[@"StatusCode"] integerValue];
        
        _speed = [trackingInfo[@"Speed"] doubleValue];
        
        _trackingTime = [trackingInfo[@"TrackTime"] dateValue];
        
        _driverId = [trackingInfo[@"DriverID"] integerValue];
        
        _driverName = trackingInfo[@"DriverName"];
        
        _driverPhone = trackingInfo[@"DriverPhone"];
    }
    return self;
}

@end
