//
//  KSUserManagement.h
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSUser;

typedef void(^KSUserManagementCallback)(BOOL);

@interface KSUserManagement : NSObject

+ (KSUserManagement *)instance;

+ (BOOL)isLoggedIn;

- (void)login:(NSString *)phone password:(NSString *)password completion:(KSUserManagementCallback)callback;

- (void)logout;

- (KSUser *)user;

@end
