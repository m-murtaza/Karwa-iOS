//
//  KSSessionInfo.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSSessionInfo : NSObject

@property (nonatomic, readonly) NSString *sessionId;
@property (nonatomic, readonly) NSString *phone;
@property (nonatomic, readonly) NSString *pushToken;

+ (instancetype)currentSession;

+ (void)updateSession:(NSString *)sessionId phone:(NSString *)phone;

+ (void)updateToken:(NSString *)token;

+ (void)removeSession;

@end
