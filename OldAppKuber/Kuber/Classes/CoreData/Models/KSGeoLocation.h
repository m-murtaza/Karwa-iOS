//
//  KSGeoLocation.h
//  Kuber
//
//  Created by Asif Kamboh on 8/31/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSBookmark;

@interface KSGeoLocation : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSNumber * longitude;

@property (nonatomic, retain) KSBookmark *geoLocationToBookmark;

@end
