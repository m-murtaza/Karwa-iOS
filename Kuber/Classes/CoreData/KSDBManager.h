//
//  KSDBManager.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSUser;
@class KSTrip;

@interface KSDBManager : NSObject

+ (instancetype)instance;

+ (void)saveContext:(void(^)())completionBlock;

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon;

+ (void)saveLocationsData:(NSArray *)locations;

- (void)saveContext:(void(^)())completionBlock;

@end

