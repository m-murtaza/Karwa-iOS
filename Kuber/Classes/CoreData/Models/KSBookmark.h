//
//  KSBookmark.h
//  Kuber
//
//  Created by Asif Kamboh on 8/4/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSUser;

@interface KSBookmark : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * bookmarkId;
@property (nonatomic, retain) KSUser *user;

@end
