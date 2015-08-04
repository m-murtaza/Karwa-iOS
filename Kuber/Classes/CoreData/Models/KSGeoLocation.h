//
//  KSGeoLocation.h
//  Kuber
//
//  Created by Asif Kamboh on 8/3/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KSGeoLocation : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSNumber * longitude;

@end
