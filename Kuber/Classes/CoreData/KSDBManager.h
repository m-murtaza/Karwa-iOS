//
//  KSDBManager.h
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSUser;

@interface KSDBManager : NSObject

+ (instancetype)instance;

+ (void)saveContext;


@end

