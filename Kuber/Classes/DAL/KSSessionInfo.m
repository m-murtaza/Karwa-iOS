//
//  KSSessionInfo.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSSessionInfo.h"

@implementation KSSessionInfo

+ (instancetype)instance {
    static KSSessionInfo *_instance;
    static dispatch_once_t dispatchQueueToken;
    
    dispatch_once(&dispatchQueueToken, ^{
        _instance = [[KSSessionInfo alloc] init];
    });
    return _instance;
}

+ (instancetype)currentSession {
    return [self instance];
}

+ (void)updateSession:(NSString *)sessionId phone:(NSString *)phone {
    [[self instance] updateSession:sessionId phone:phone];
}

+ (void)removeSession {
    [[self instance] removeSession];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaultStore = [NSUserDefaults standardUserDefaults];
        NSDictionary *sessionInfo = [defaultStore objectForKey:@"KSLoggedInUserInfo"];
        if (sessionInfo) {
            _phone = [sessionInfo objectForKey:@"phone"];
            _sessionId = [sessionInfo objectForKey:@"sid"];
        }
    }
    return self;
}

- (void)saveSessionInfo:(NSDictionary *)sessionInfo {
    
    NSUserDefaults *defaultStore = [NSUserDefaults standardUserDefaults];
    [defaultStore setObject:sessionInfo forKey:@"KSLoggedInUserInfo"];
    
    [defaultStore synchronize];
}

- (void)updateSession:(NSString *)sessionId phone:(NSString *)phone {
    
    _sessionId = sessionId;
    _phone = phone;
    
    [self saveSessionInfo:@{ @"sid": sessionId, @"phone": phone }];
}

- (void)removeSession {
    
    _sessionId = nil;
    _phone = nil;
    
    [self saveSessionInfo:@{}];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %lx; sid: %@; phone: %@>",
            NSStringFromClass([self class]), (unsigned long)self, _sessionId, _phone];
}

@end
