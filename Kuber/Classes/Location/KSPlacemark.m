//
//  KSPlacemark.m
//  Kuber
//
//  Created by Asif Kamboh on 6/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSPlacemark.h"

@implementation KSPlacemark

+ (instancetype)placemarkWithLocationData:(NSDictionary *)locationData {

    return [[self alloc] initWithLocationData:locationData];
}

- (instancetype)initWithLocationData:(NSDictionary *)locationData {

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationData[@"latitude"] doubleValue], [locationData[@"longitude"] doubleValue]);
    return [self initWithCoordinate:coordinate addressDictionary:locationData];
}

@end
