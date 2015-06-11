//
//  KSAddress.m
//  Kuber
//
//  Created by Asif Kamboh on 6/9/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAddress.h"
#import "KSLocationManager.h"

@interface KSAddress ()
{
    CLLocation *_location;
    NSString *_landmark;
}

@end

@implementation KSAddress

+ (instancetype)addressWithLandmark:(NSString *)landmark {
    if (!landmark.length) {
        return nil;
    }
    return [[self alloc] initWithLandmark:landmark];
}

+ (instancetype)addressWithLocation:(CLLocation *)location {
    if (!location) {
        return nil;
    }
    return [[self alloc] initWithLocation:location];
}

+ (instancetype)addressWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[self alloc] initWithCoordinate:coordinate];
}

+ (instancetype)addressWithLandmark:(NSString *)landmark location:(CLLocation *)location {
    if (!landmark && !location) {
        return nil;
    }
    return [[self alloc] initWithLandmark:landmark location:location];
}

+ (instancetype)addressWithLandmark:(NSString *)landmark coordinate:(CLLocationCoordinate2D)coordinate {
    return [self addressWithLandmark:landmark location:[CLLocation locationWithCoordinate:coordinate]];
}

+ (instancetype)addressWithPlacemark:(CLPlacemark *)placemark {
    if (!placemark) {
        return nil;
    }
    return [[self alloc] initWithPlacemark:placemark];
}

- (instancetype)initWithLandmark:(NSString *)landmark {
    self = [super init];
    if (self) {
        _landmark = landmark;
        // A search query text should be good enough to identify itself
        if (_landmark.length > 2) {
            [KSLocationManager nearestPlacemarksInCountry:kKSCountryForLocationSearch searchQuery:_landmark completion:^(NSArray *placemarks) {
                if (placemarks.count) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    _location = placemark.location;
                }
            }];
        }
    }
    return self;
}

- (instancetype)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (self) {
        _location = location;
        if (_location) {
            [KSLocationManager placemarkForLocation:location completion:^(CLPlacemark *placemark) {
                _landmark = placemark.address;
            }];
        }
    }
    return self;
}

- (instancetype)initWithLandmark:(NSString *)landmark location:(CLLocation *)location {
    if (!landmark) {
        self = [self initWithLocation:location];
    }
    else if (!location) {
        self = [self initWithLandmark:landmark];
    }
    else if (self = [super init]) {
        _landmark = landmark;
        _location = location;
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithLocation:[CLLocation locationWithCoordinate:coordinate]];
}

- (instancetype)initWithLandmark:(NSString *)landmark coordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithLandmark:landmark location:[CLLocation locationWithCoordinate:coordinate]];
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark {
    return [self initWithLandmark:placemark.address location:placemark.location];
}

- (CLLocation *)location {
    return _location;
}

- (CLLocationCoordinate2D)coordinate {
    return _location.coordinate;
}

- (NSString *)landmark {
    return _landmark;
}

@end
