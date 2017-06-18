//
//  KSTripRating.h
//  Kuber
//
//  Created by Asif Kamboh on 8/4/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSTrip;

@interface KSTripRating : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * serviceRating;
@property (nonatomic, retain) NSString * issue;
@property (nonatomic, retain) KSTrip *trip;

@end
