//
//  KSUserManagement.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSUserManagement.h"

@implementation KSUserManagement

+ (BOOL)isLoggedIn {
    return [[self instance] isLoggedIn];
}

+ (KSUserManagement *)instance {
    static KSUserManagement *instance = NULL;
    if (!instance) {
        // TODO: Make use of global queues
        instance = [[KSUserManagement alloc] init];
    }
    return instance;
}

- (BOOL)isLoggedIn {
    return !![self user];
}

- (void)login:(NSString *)phone password:(NSString *)password completion:(KSUserManagementCallback)callback {

}

- (void)logout {
    
}

- (KSUser *)user {
    return nil;
}

@end
