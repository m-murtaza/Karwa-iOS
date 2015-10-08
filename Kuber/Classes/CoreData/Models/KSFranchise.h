//
//  KSFranchise.h
//  Kuber
//
//  Created by Asif Kamboh on 10/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KSFranchise : NSManagedObject

@property (nonatomic, retain) NSNumber * franchiseId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * logoUrl;

@end
