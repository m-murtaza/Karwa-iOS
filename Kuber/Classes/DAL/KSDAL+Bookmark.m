//
//  KSDAL+Bookmark.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+Bookmark.h"

#import "KSDBManager.h"
#import "KSWebClient.h"

#import "KSUser.h"
#import "KSTrip.h"
#import "KSTripRating.h"
#import "KSBookmark.h"
#import "KSGeoLocation.h"

#import "KSSessionInfo.h"
#import "CoreData+MagicalRecord.h"

@implementation KSDAL (KSBookmark)

#pragma mark -
#pragma mark - Favorites

+ (void)syncBookmarksWithCompletion:(KSDALCompletionBlock)completionBlock {

    KSWebClient *webClient = [KSWebClient instance];

    [webClient GET:@"/bookmarks" params:@{} completion:^(BOOL success, NSDictionary *response) {

        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        KSUser *user = [KSDAL loggedInUser];

        if (KSAPIStatusSuccess == status) {

            for (KSBookmark *bookmark in user.bookmarks.allObjects) {
                bookmark.user = nil;
            }
            [user removeBookmarks:user.bookmarks];

            NSArray *favorites = response[@"data"];

            for (NSDictionary *favorite in favorites) {

                KSBookmark *bookmark = [KSBookmark objWithValue:favorite[@"Id"] forAttrib:@"bookmarkId"];
                bookmark.name = favorite[@"Name"];
#warning TODO: Verify if the JSON data is Double
                bookmark.latitude = [NSNumber numberWithDouble:[favorite[@"Lat"] doubleValue]];
                bookmark.longitude = [NSNumber numberWithDouble:[favorite[@"Lon"] doubleValue]];
                bookmark.address = favorite[@"Address"];

                bookmark.user = user;
                [user addBookmarksObject:bookmark];
            }
            [KSDBManager saveContext];
        }
        completionBlock(status, [user.bookmarks allObjects]);
    }];
}

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *bookmarkData = @{
        @"Name": name,
        @"Lat": @(coordinate.latitude),
        @"Lon": @(coordinate.longitude)
    };

    KSWebClient *webClient = [KSWebClient instance];

    [webClient POST:@"/bookmark" data:bookmarkData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            NSDictionary *responseData = response[@"data"];
            
            KSBookmark *bookmark = [KSBookmark objWithValue:responseData[@"Id"] forAttrib:@"bookmarkId"];
            bookmark.name = responseData[@"Name"];
#warning TODO: Verify if the JSON data is Double
            bookmark.latitude = responseData[@"Lat"];
            bookmark.longitude = responseData[@"Lon"];
            bookmark.address = responseData[@"Address"];

            KSUser *user = [KSDAL loggedInUser];
            bookmark.user = user;

            [user addBookmarksObject:bookmark];
            
            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

+ (void)updateBookmark:(KSBookmark *)aBookmark withName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *bookmarkData = @{
                                   @"Name": name,
                                   @"Lat": @(coordinate.latitude),
                                   @"Lon": @(coordinate.longitude)
                                   };

    __block KSBookmark *bookmark = aBookmark;
    KSWebClient *webClient = [KSWebClient instance];
    NSString *uri = [NSString stringWithFormat:@"/bookmark/%@", bookmark.bookmarkId];

    [webClient POST:uri data:bookmarkData completion:^(BOOL success, NSDictionary *response) {

        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];

        if (KSAPIStatusSuccess == status) {

            bookmark.name = name;
            bookmark.latitude = @(coordinate.latitude);
            bookmark.longitude = @(coordinate.longitude);
            bookmark.address = response[@"data"][@"Address"];

            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

+ (void)deleteBookmark:(KSBookmark *)aBookmark completion:(KSDALCompletionBlock)completionBlock {

    __block KSBookmark *bookmark = aBookmark;

    KSWebClient *webClient = [KSWebClient instance];

    NSString *uri = [NSString stringWithFormat:@"/bookmark/%@", bookmark.bookmarkId];

    [webClient DELETE:uri completion:^(BOOL success, NSDictionary *response) {
        
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];

        if (KSAPIStatusSuccess == status) {

            KSUser *user = [KSDAL loggedInUser];
            [user removeBookmarksObject:bookmark];
            [bookmark MR_deleteEntity];
            [KSDBManager saveContext];
        }
        completionBlock(status, nil);
    }];
}

@end
