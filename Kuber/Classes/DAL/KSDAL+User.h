//
//  KSDAL+User.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSWebClient.h"

@class KSUser;

@interface KSDAL (KSUser)

+ (KSUser *)userWithPhone:(NSString *)phone;

+ (void)logoutUser;

+ (void)saveLoggedInUserSession:(NSString *)sessionId phone:(NSString *)phone;

+ (void)registerUser:(KSUser *)user password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)loginUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)verifyUserWithPhone:(NSString *)phone code:(NSString *)accessCode completion:(KSDALCompletionBlock)completionBlock;

+ (void)sendOtpOnPhone:(NSString *)phone completion:(KSDALCompletionBlock)completionBlock;

+ (void)resetPasswordForUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateUserInfoWithEmail:(NSString *)email withName:(NSString *)userName completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateUserPassword:(NSString *)oldPassword withPassword:(NSString *)newPassword completion:(KSDALCompletionBlock)completionBlock;

+(void)updateUserWithPushToken:(NSString*)pushToken completion:(KSDALCompletionBlock)completionBlock;

@end
