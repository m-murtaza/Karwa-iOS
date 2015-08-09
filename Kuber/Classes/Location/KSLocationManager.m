//
//  KSLocationManager.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "KSWebClient.h"
#import "KSDAL.h"

#import "KSGeoLocation.h"

@interface KSLocationManager ()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    NSMutableArray *_completionBlocks;
    CLGeocoder *_geocoder;
//    KSGeoLocation *_lastPlacemark;
    MKLocalSearch *_localSearchManager;
}

@end

@implementation KSLocationManager

+ (instancetype)instance {
    static KSLocationManager *_instance = nil;
    static dispatch_once_t dispatchQueueToken;

    dispatch_once(&dispatchQueueToken, ^{
        _instance = [[KSLocationManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 40.; // kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
        _geocoder = [[CLGeocoder alloc] init];
        _completionBlocks = [NSMutableArray array];
        
    }
    return self;
}

+ (CLLocation *)start {
    KSLocationManager *manager = [self instance];
    return [manager start];
}

+ (CLLocation *)stop {
    KSLocationManager *manager = [self instance];
    return [manager stop];
}

+ (CLLocation *)location {
    KSLocationManager *manager = [self instance];
    return [manager location];
}

+ (CLPlacemark *)placemark {
    return [[self instance] placemark];
}

+ (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion {
    [[self instance] placemarkWithBlock:completion];
}

+ (void)placemarkForLocation:(CLLocation *)location completion:(KSPlacemarkCompletionBlock)completion {
    [[self instance] placemarkForLocation:location completion:completion];
}

+ (void)placemarkForCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkCompletionBlock)completion {
    return [self placemarkForLocation:[CLLocation locationWithCoordinate:coordinate] completion:completion];
}

+ (void)nearestPlacemarksInCountry:(NSString *)country searchQuery:(NSString *)address completion:(KSPlacemarkListCompletionBlock)completion {
    [[self instance] nearestPlacemarksInCountry:country searchQuery:address completion:completion];
}

- (CLLocation *)start {
    [_locationManager startUpdatingLocation];
    return _locationManager.location;
}

- (CLLocation *)stop {
    [_locationManager stopUpdatingLocation];
    CLLocation *stoppingLocation = _lastLocation;
    return stoppingLocation;
}

- (CLLocation *)location {
    if (_lastLocation) {
        return _lastLocation;
    }
    return _locationManager.location;
}

//- (CLPlacemark *)placemark {
//    return _lastPlacemark;
//}

- (void)placemarkWithBlock:(KSPlacemarkCompletionBlock)completion {
    [self start];
    if (self.location) {
        [self placemarkForLocation:self.location completion:completion];
    }
    else {
        [_completionBlocks addObject:completion];
    }
}

- (void)placemarkForLocation:(CLLocation *)location completion:(KSPlacemarkCompletionBlock)completionBlock {

    __block KSLocationManager *locationManager = self;

    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count) {
            CLPlacemark *placemark = [placemarks firstObject];

            KSGeoLocation *geolocation = [KSDAL addGeolocationWithCoordinate:placemark.location.coordinate area:placemark.administrativeArea address:placemark.address];

            completionBlock(geolocation);
        }
        else {
            [locationManager reverseGeocodeLocation:location completion:^(NSArray *placemarks) {
                completionBlock([placemarks firstObject]);
            }];
        }
    }];
}

/*
- (NSArray *)addressTokens:(NSString *)address {

    NSArray *addressTokens = [address componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",:; \t"]];
    NSLog(@"Address Tokens: %@", addressTokens);
    return addressTokens;
}*/

/*
- (void)nearestPlacemarksForPlace:(CLPlacemark *)placemark toAddress:(NSString *)address completion:(KSPlacemarkListCompletionBlock)completion {
    // Format address string based on given string
    NSString *addressString = nil;
    if (!placemark) {
        placemark = _lastPlacemark;
    }
    if (!placemark) {
        addressString = address;
    }
    else if (false) {

        NSArray *addressTokens = [self addressTokens:address];
        NSMutableArray *nameComponents = [NSMutableArray array];
        
        __block NSMutableDictionary *optionalAddressComponents = [NSMutableDictionary dictionary];
        BOOL (^buildOptionalAddressComponent)(NSString *, NSString *) =  ^BOOL(NSString *key, NSString *value) {
            BOOL inserted = FALSE;
            if (!optionalAddressComponents[key]) {
                NSString *placemarkValue = [placemark performSelector:NSSelectorFromString(key)];
                if ([placemarkValue startsWithCaseInsensitive:value]) {
                    [optionalAddressComponents setObject:placemarkValue forKey:key];
                    inserted = TRUE;
                }
            }
            return inserted;
        };

        for (NSString *addressComponent in addressTokens) {
            if (addressComponent.length) {
                BOOL inserted = buildOptionalAddressComponent(@"subLocality", addressComponent);
                if (!inserted) {
                    inserted = buildOptionalAddressComponent(@"locality", addressComponent);
                }
                if (!inserted) {
                    inserted = buildOptionalAddressComponent(@"subAdministrativeArea", addressComponent);
                }
                if (!inserted) {
                    inserted = buildOptionalAddressComponent(@"administrativeArea", addressComponent);
                }
                if (!inserted) {
                    inserted = buildOptionalAddressComponent(@"postalCode", addressComponent);
                }
                if (!inserted) {
                    inserted = buildOptionalAddressComponent(@"country", addressComponent);
                }
                if (!inserted) {
                    [nameComponents addObject: addressComponent];
                }
            }
        }

        __block NSMutableArray *finalAddressComponents = [NSMutableArray arrayWithArray:nameComponents];
        void (^appendOptionalAddressComponent)(NSString *, NSString *) = ^(NSString *key, NSString *defaultVal) {
            NSString *value = [optionalAddressComponents[key] length] ? optionalAddressComponents[key] : defaultVal;
            if (value.length && NSNotFound == [finalAddressComponents indexOfObject:value]) {
                [finalAddressComponents addObject:value];
            }
        };

        appendOptionalAddressComponent(@"subLocality", nil);
        appendOptionalAddressComponent(@"locality", placemark.locality);
        appendOptionalAddressComponent(@"subAdministrativeArea", nil);
        appendOptionalAddressComponent(@"administrativeArea", placemark.administrativeArea);
        appendOptionalAddressComponent(@"postalCode", nil);
        appendOptionalAddressComponent(@"country", placemark.country);
        
        addressString = [finalAddressComponents componentsJoinedByString:@" "];
    }
    NSLog(@"Address String is: %@", addressString);
    NSLog(@"Region is: %@", placemark.region);
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:placemark.location.coordinate radius:100000.0 identifier:@"user_location"];
    [_geocoder geocodeAddressString:addressString inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
        completion(placemarks);
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}*/

#pragma mark -
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastLocation = [locations lastObject];

    // Geocode the location

    // Finish all completion blocks

    NSArray *completionBlocks = [NSArray arrayWithArray:_completionBlocks];

    void(^placemarkCallback)(KSGeoLocation *) = ^(KSGeoLocation *placemark) {
//        if (placemark) {
//            _lastPlacemark = placemark;
//        }
        for (KSPlacemarkCompletionBlock completionBlock in completionBlocks) {
            completionBlock(placemark);
        }
    };

    [self locationWithCoordinate:_lastLocation.coordinate completion:placemarkCallback];

    [_completionBlocks removeAllObjects];
}

#pragma mark -
#pragma mark - Geocoding from Web client

- (void)geocodeWithParams:(NSDictionary *)params completion:(KSPlacemarkListCompletionBlock)completionBlock {
    [KSDAL geocodeWithParams:params completion:^(KSAPIStatus status, NSDictionary *response) {
#warning TODO: ADD Code for making KSPlacemarks from server data
        completionBlock([NSArray array]);
    }];
}

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkListCompletionBlock)completionBlock {

    NSDictionary *params = @{@"latitude": [NSNumber numberWithDouble:coordinate.latitude],
                             @"longitude": [NSNumber numberWithDouble:coordinate.longitude]};
    [self geocodeWithParams:params completion:completionBlock];
}

- (void)reverseGeocodeLocation:(CLLocation *)location completion:(KSPlacemarkListCompletionBlock)completionBlock {
    
    [self reverseGeocodeCoordinate:location.coordinate completion:completionBlock];
}

- (void)placemarksMatchingQuery:(NSString *)query country:(NSString *)country completion:(KSPlacemarkListCompletionBlock)completionBlock {
    if (!country) {
        country = @"";
    }
    NSArray *placemarks = [KSDAL locationsMatchingText:query];
    if (placemarks.count) {
        
        [self performSelector:@selector(invokeBlock:) withObject:^() {

            completionBlock(placemarks);

        } afterDelay:0.1];
    }
    else {

        CLRegion *region = [[CLCircularRegion alloc] initWithCenter:_lastLocation.coordinate radius:100000.0 identifier:@"user_location"];
        [_geocoder geocodeAddressString:query inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
            NSMutableArray *locations = [NSMutableArray array];
            for (CLPlacemark *placemark in placemarks) {
                [locations addObject:[KSDAL addGeolocationWithCoordinate:placemark.location.coordinate area:placemark.administrativeArea address:placemark.address]];
            }
            completionBlock(locations);
            if (error) {
                NSLog(@"%@", error);
            }
        }];
        
    }
    NSDictionary *params = @{@"query": query, @"country": country};
    [self geocodeWithParams:params completion:completionBlock];
}

#pragma mark -
#pragma mark - Geocoding using locations data

- (void)invokeBlock:(void(^)())blockFn {
    
    blockFn();
}

- (void)locationWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkCompletionBlock)completionBlock {

    KSGeoLocation *location =  [KSDAL nearestLocationMatchingLatitude:coordinate.latitude longitude:coordinate.longitude];
    if (location) {
        [self performSelector:@selector(invokeBlock:) withObject:^() {
            completionBlock(location);
        } afterDelay:0.01];
    }
    else {
        [self placemarkForLocation:[CLLocation locationWithCoordinate:coordinate] completion:completionBlock];
    }

}


@end
