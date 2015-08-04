//
//  KSDAL.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSConstants.h"

@class KSUser;

typedef void(^KSDALCompletionBlock)(KSAPIStatus status, id response);

@interface KSDAL : NSObject

+ (KSAPIStatus)statusFromResponse:(NSDictionary *)response success:(BOOL)success;

+ (KSUser *)loggedInUser;

@end
