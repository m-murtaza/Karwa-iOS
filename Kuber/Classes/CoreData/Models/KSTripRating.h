//
//  KSTripRating.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSTrip;

@interface KSTripRating : NSManagedObject

@property (nonatomic, retain) NSNumber * serviceRating;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) KSTrip *trip;

@end
