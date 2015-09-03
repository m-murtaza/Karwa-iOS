//
//  KSBookmark.h
//  Kuber
//
//  Created by Asif Kamboh on 8/31/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSGeoLocation, KSUser;

@interface KSBookmark : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * bookmarkId;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) KSUser *user;
@property (nonatomic, retain) KSGeoLocation *bookmarkToGeoLocation;

@end
