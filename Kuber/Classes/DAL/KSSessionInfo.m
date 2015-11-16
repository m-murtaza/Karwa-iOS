//
//  KSSessionInfo.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSSessionInfo.h"

@interface KSSessionInfo ()
{
    
}

@end

NSString * const KSPhoneKey = @"KSSessionPhone";
NSString * const KSDeviceTokenKey = @"KSDeviceToken";
NSString * const KSSessionIdKey = @"KSSessionID";
NSString * const KSLocationsSyncTimeKey = @"KSLocationsSyncTime";

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

+ (void)updateToken:(NSString *)token {

    [[self instance] updateToken:token];
}

+ (void)removeSession {

    [[self instance] removeSession];
}

+ (void)updateLocationsSyncTime {

    [[self instance] updateLocationsSyncTime];
}

+ (NSTimeInterval)locationsSyncTime {
    
    return [[self instance] locationsSyncTime];
}


- (instancetype)init {

    self = [super init];
    if (self) {

    }
    return self;
}

- (void)saveValue:(id)value forKey:(NSString *)key {
    
    NSUserDefaults *defaultStore = [NSUserDefaults standardUserDefaults];
    if (value) {
        [defaultStore setObject:value forKey:key];
    }
    else {
        [defaultStore removeObjectForKey:key];
    }
    
    [defaultStore synchronize];
}

- (void)updateSession:(NSString *)sessionId phone:(NSString *)phone {
    
    [self saveValue:phone forKey:KSPhoneKey];
    [self saveValue:sessionId forKey:KSSessionIdKey];
    
}

- (void)updateToken:(NSString *)token {

    [self saveValue:token forKey:KSDeviceTokenKey];
}

- (void)removeSession {
    
    [self saveValue:nil forKey:KSPhoneKey];
    [self saveValue:nil forKey:KSSessionIdKey];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"<%@: %lx; sid: %@; phone: %@; token: %@>",
            NSStringFromClass([self class]), (unsigned long)self, self.sessionId, self.phone, self.pushToken];
}

- (void)updateLocationsSyncTime {

    NSNumber *timeObj = [NSNumber numberWithDouble:[[[NSDate alloc] init] timeIntervalSince1970]];
    [self saveValue:timeObj forKey:KSLocationsSyncTimeKey];
}

- (NSTimeInterval)locationsSyncTime {
    
    return [[NSUserDefaults standardUserDefaults] doubleForKey:KSLocationsSyncTimeKey];
}

- (NSString *)sessionId {

    return [[NSUserDefaults standardUserDefaults] stringForKey:KSSessionIdKey];
}

- (NSString *)phone {
    
    return [[NSUserDefaults standardUserDefaults] stringForKey:KSPhoneKey];
}

- (NSString *)pushToken {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:KSDeviceTokenKey];

#if (TARGET_IPHONE_SIMULATOR)
    if (!token.length) {
        token = @"TARGET_IPHONE_SIMULATOR";
    }
#endif

    return token;
}

@end
