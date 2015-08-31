//
//  KSDAL+Bookmark.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSDAL.h"

@class KSBookmark;

@interface KSDAL (KSBookmark)

+ (void)syncBookmarksWithCompletion:(KSDALCompletionBlock)completionBlock;

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address completion:(KSDALCompletionBlock)completionBlock;

+ (void)updateBookmark:(KSBookmark *)aBookmark withName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock;

+ (void)deleteBookmark:(KSBookmark *)aBookmark completion:(KSDALCompletionBlock)completionBlock;


+(void) addBookMarkForGeoLocation:(KSGeoLocation*)gLoc;
+(void) removeBookMarkForGeoLocation:(KSGeoLocation*)gLoc;
@end
