//
//  KSPlacemark.h
//  Kuber
//
//  Created by Asif Kamboh on 6/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KSPlacemark : MKPlacemark

+ (instancetype)placemarkWithLocationData:(NSDictionary *)locationData;

- (instancetype)initWithLocationData:(NSDictionary *)locationData;

@end
