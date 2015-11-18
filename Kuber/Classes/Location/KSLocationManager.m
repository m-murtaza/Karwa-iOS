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

    KSLocationManager *locationManager = self;
    [locationManager reverseGeocodeLocation:location completion:^(NSArray *placemarks) {
        if (placemarks && placemarks.count > 0) {
            NSDictionary *revGoecodeData = [placemarks firstObject];
            KSGeoLocation *geolocation = [KSDAL addGeolocationWithCoordinate:location.coordinate
                                                                        area:
                                          [revGoecodeData valueForKey:@"area"]
                                                                     address:[revGoecodeData valueForKey:@"address"]
                                                                          Id:[revGoecodeData valueForKey:@"id"]];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                  action:@"Reverse geocode from KISS Server"
                                                                   label:[NSString stringWithFormat:@"coordinate %f-%f | landmark:%@",location.coordinate.latitude,location.coordinate.longitude,geolocation.address]
                                                                   value:nil] build]];

        
            completionBlock(geolocation);
        }
        else{
            [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (placemarks.count) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    
                    KSGeoLocation *geolocation = [KSDAL addGeolocationWithCoordinate:placemark.location.coordinate area:placemark.administrativeArea address:placemark.address];
                    
                    
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                                          action:@"Reverse geocode from Apple"
                                                                           label:[NSString stringWithFormat:@"coordinate %f-%f | landmark:%@",location.coordinate.latitude,location.coordinate.longitude,geolocation.address]
                                                                           value:nil] build]];
                    
                    completionBlock(geolocation);
                }
                else
                    completionBlock(nil);
            }];
        }
    }];
    
}


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

        if (KSAPIStatusSuccess ==status) {
        
            completionBlock(response[@"data"]);
        }
        else{
        
            completionBlock(nil);
        }
        
    }];
}

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkListCompletionBlock)completionBlock {

    /*NSDictionary *params = @{@"latitude": [NSNumber numberWithDouble:coordinate.latitude],
                             @"longitude": [NSNumber numberWithDouble:coordinate.longitude]};*/
    NSDictionary *params = @{@"lat": [NSNumber numberWithDouble:coordinate.latitude],
                             @"lon": [NSNumber numberWithDouble:coordinate.longitude]};
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
    NSMutableArray *locations = [NSMutableArray arrayWithArray:placemarks];
    completionBlock(locations);
//    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:_lastLocation.coordinate radius:30000.0 identifier:@"user_location"];
//
//    NSDictionary *addressDictionary = @{
//        @"Country": @"Qatar",
//        @"Name": query,
//        @"Street": query
//    };
//    if (![query.lowercaseString containsString:@"qatar"]) {
//        query = [query stringByAppendingString:@", Qatar"];
//    }
//    [_geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (!error) {
//            for (CLPlacemark *placemark in placemarks) {
//                if ([region containsCoordinate:placemark.location.coordinate]) {
//                    [locations addObject:[KSDAL addGeolocationWithCoordinate:placemark.location.coordinate area:placemark.administrativeArea address:placemark.address]];
//                }
//            }
//        }
//        else {
//            NSLog(@"%@", error);
//        }
//        completionBlock(locations);
//    }];
    
//    if (placemarks.count) {
//
//        [self performSelector:@selector(invokeBlock:) withObject:^() {
//
//            completionBlock(placemarks);
//
//        } afterDelay:0.1];
//    }
//    else {
//
//        CLRegion *region = [[CLCircularRegion alloc] initWithCenter:_lastLocation.coordinate radius:100000.0 identifier:@"user_location"];
//        [_geocoder geocodeAddressString:query inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
//            NSMutableArray *locations = [NSMutableArray array];
//            for (CLPlacemark *placemark in placemarks) {
//                [locations addObject:[KSDAL addGeolocationWithCoordinate:placemark.location.coordinate area:placemark.administrativeArea address:placemark.address]];
//            }
//            completionBlock(locations);
//            if (error) {
//                NSLog(@"%@", error);
//            }
//        }];
//    
//    }
//    NSDictionary *params = @{@"query": query, @"country": country};
//    [self geocodeWithParams:params completion:completionBlock];
}

#pragma mark -
#pragma mark - Geocoding using locations data

- (void)invokeBlock:(void(^)())blockFn {
    
    blockFn();
}

- (void)locationWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(KSPlacemarkCompletionBlock)completionBlock {

    //[self placemarkForLocation:[CLLocation locationWithCoordinate:coordinate] completion:completionBlock];
    
    KSGeoLocation *location =  [KSDAL nearestLocationMatchingLatitude:coordinate.latitude longitude:coordinate.longitude];
    if (location) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Booking"
                                                              action:@"Reverse geocode from LocalDB"
                                                               label:[NSString stringWithFormat:@"coordinate %f-%f | landmark:%@",coordinate.latitude,coordinate.longitude,location.address]
                                                               value:nil] build]];
        
        [self performSelector:@selector(invokeBlock:) withObject:^() {
            completionBlock(location);
        } afterDelay:0.01];
    }
    else {
        
        
        [self placemarkForLocation:[CLLocation locationWithCoordinate:coordinate] completion:completionBlock];
    }

}


@end
