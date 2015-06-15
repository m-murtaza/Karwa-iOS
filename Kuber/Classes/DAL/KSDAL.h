//
//  KSDAL.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSWebClient.h"

typedef void(^KSDALCompletionBlock)(KSAPIStatus, id);

@class KSUser;
@class KSTrip;
@class KSBookmark;

@interface KSDAL : NSObject

+ (KSUser *)userWithPhone:(NSString *)phone;

+ (KSUser *)loggedInUser;

+ (void)logoutUser;

+ (void)saveLoggedInUserSession:(NSString *)sessionId phone:(NSString *)phone;

+ (void)registerUser:(KSUser *)user password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)loginUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)verifyUserWithPhone:(NSString *)phone code:(NSString *)accessCode completion:(KSDALCompletionBlock)completionBlock;

+ (void)resetPasswordForUserWithPhone:(NSString *)phone password:(NSString *)password completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateUserInfoWithEmail:(NSString *)email withName:(NSString *)userName completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateUserPassword:(NSString *)oldPassword withPassword:(NSString *)newPassword completion:(KSDALCompletionBlock)completionBlock;

+ (KSTrip *)tripWithLandmark:(NSString *)landmark lat:(CGFloat)lat lon:(CGFloat)lon;

+ (void)bookTrip:(KSTrip *)trip completion:(KSDALCompletionBlock)completionBlock;

+ (void)geocodeWithParams:(NSDictionary *)params completion:(KSDALCompletionBlock)completionBlock;

+ (void)syncBookmarksWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateBookmark:(KSBookmark *)aBookmark withName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock;

+ (void)deleteBookmark:(KSBookmark *)aBookmark completion:(KSDALCompletionBlock)completionBlock;

@end
