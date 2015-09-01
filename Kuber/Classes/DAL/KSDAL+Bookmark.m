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

    static BOOL isRunning = NO;
    static NSMutableArray *blocks = nil;
    
    if (!blocks) {
        blocks = [NSMutableArray array];
    }
    
    if (isRunning) {
        [blocks addObject:completionBlock];
        return;
    }
    // Add to existing blocks
    [blocks addObject:completionBlock];

    isRunning = YES;

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
                bookmark.latitude = [NSNumber numberWithDouble:[favorite[@"Lat"] doubleValue]];
                bookmark.longitude = [NSNumber numberWithDouble:[favorite[@"Lon"] doubleValue]];
                if ([favorite[@"Address"] length]) {
                    bookmark.address = favorite[@"Address"];
                }

                bookmark.user = user;
                [user addBookmarksObject:bookmark];
                
                if ([favorite[@"LocationID"] integerValue] == 474) {
                    NSLog(@"------This is the line you are searching for. -------");
                }
                //Goe location
                if ([favorite[@"LocationID"] integerValue] != 0) {
                    
                    KSGeoLocation *gLoc = [KSDAL locationsWithLocationID:favorite[@"LocationID"]];
                    if(gLoc) {
                        
                        gLoc.geoLocationToBookmark = bookmark;
                        bookmark.bookmarkToGeoLocation =  gLoc;
                    }
                }
            }
            [KSDBManager saveContext:^{
            
                isRunning = NO;
                
                for (KSDALCompletionBlock block in blocks) {
                    block(status, [user.bookmarks allObjects]);
                }
                
                [blocks removeAllObjects];

            
            }];
        }
        else {
            isRunning = NO;
            
            for (KSDALCompletionBlock block in blocks) {
                block(status, [user.bookmarks allObjects]);
            }
            
            [blocks removeAllObjects];
        }
    }];
}

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address LocationID:(NSNumber*)locId Preference:(NSNumber*)preference completion:(KSDALCompletionBlock)completionBlock {

    NSDictionary *bookmarkData = @{
                                   @"Name"      : name,
                                   @"Lat"       : @(coordinate.latitude),
                                   @"Lon"       : @(coordinate.longitude),
                                   @"LocationID": @(locId ? [locId integerValue] : 0),
                                   @"Preference": @(preference ? [preference integerValue] : 0)
                                   };
    
    KSWebClient *webClient = [KSWebClient instance];
    
    [webClient POST:@"/bookmark" data:bookmarkData completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            NSDictionary *responseData = response[@"data"];
            
            KSBookmark *bookmark = [KSBookmark objWithValue:responseData[@"Id"] forAttrib:@"bookmarkId"];
            bookmark.name = responseData[@"Name"];
            bookmark.latitude = [NSNumber numberWithDouble:[responseData[@"Lat"] doubleValue]];
            bookmark.longitude = [NSNumber numberWithDouble:[responseData[@"Lon"] doubleValue]];
            
            bookmark.address = address;
            if ([responseData[@"Address"] length]) {
                bookmark.address = responseData[@"Address"];
            }
            
            //add User
            KSUser *user = [KSDAL loggedInUser];
            bookmark.user = user;
            
            [user addBookmarksObject:bookmark];
            
            //Goe location
            if ([responseData[@"LocationID"] integerValue] != 0) {
                
                KSGeoLocation *gLoc = [KSDAL locationsWithLocationID:responseData[@"LocationID"]];
                if(gLoc) {
                    
                    gLoc.geoLocationToBookmark = bookmark;
                    bookmark.bookmarkToGeoLocation =  gLoc;
                }
            }
            
            [KSDBManager saveContext:^{
                completionBlock(status, bookmark);
            }];
        }
        else {
            completionBlock(status, nil);
        }
    }];
}

+ (void)addBookmarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address completion:(KSDALCompletionBlock)completionBlock {

    
    [KSDAL addBookmarkWithName:name
                    coordinate:coordinate
                       address:address
                    LocationID:[NSNumber numberWithInt:0]
                    Preference:[NSNumber numberWithInt:0]
                    completion:^(KSAPIStatus status, id response) {
                        
                        completionBlock(status, response);
                    }];
    
    /*NSDictionary *bookmarkData = @{
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
            bookmark.latitude = [NSNumber numberWithDouble:[responseData[@"Lat"] doubleValue]];
            bookmark.longitude = [NSNumber numberWithDouble:[responseData[@"Lon"] doubleValue]];
            bookmark.address = address;
            if ([responseData[@"Address"] length]) {
                bookmark.address = responseData[@"Address"];
            }

            KSUser *user = [KSDAL loggedInUser];
            bookmark.user = user;

            [user addBookmarksObject:bookmark];
            
            [KSDBManager saveContext:^{
                completionBlock(status, bookmark);
            }];
        }
        else {
            completionBlock(status, nil);
        }
    }];*/
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
            bookmark.address = @"";
            if (response[@"data"][@"Address"]) {
                bookmark.address = response[@"data"][@"Address"];
            }
            
            //Goe location
            if ([response[@"data"][@"LocationID"] integerValue] != 0) {
                
                KSGeoLocation *gLoc = [KSDAL locationsWithLocationID:response[@"data"][@"LocationID"]];
                if(gLoc) {
                    
                    gLoc.geoLocationToBookmark = bookmark;
                    bookmark.bookmarkToGeoLocation =  gLoc;
                }
            }

            [KSDBManager saveContext:^{
                completionBlock(status, bookmark);
            }];
        }
        else {
            completionBlock(status, nil);
        }
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
            [KSDBManager saveContext:^{
                completionBlock(status, nil);
            }];
        }
        else {
            completionBlock(status, nil);
        }
    }];
}

+(void) addBookMarkForGeoLocation:(KSGeoLocation*)gLoc  withName:(NSString *)name  completion:(KSDALCompletionBlock)completionBlock
{
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [gLoc.longitude doubleValue];
    coordinate.latitude = [gLoc.latitude doubleValue];
   
    [KSDAL addBookmarkWithName:name
                    coordinate:coordinate
                       address:gLoc.address
                    LocationID:gLoc.locationId
                    Preference:[NSNumber numberWithInt:0]
                    completion:completionBlock];

}

+(void) removeBookMarkForGeoLocation:(KSGeoLocation*)gLoc  completion:(KSDALCompletionBlock)completionBlock
{
    KSBookmark * bookmark = gLoc.geoLocationToBookmark;
    __block KSGeoLocation *loc = gLoc;
    
    [KSDAL deleteBookmark:bookmark completion:^(KSAPIStatus status, id response) {
    
        loc.geoLocationToBookmark = nil;
        completionBlock(status,response);
    } ];
}
@end
