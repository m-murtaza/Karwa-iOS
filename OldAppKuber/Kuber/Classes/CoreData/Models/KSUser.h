//
//  KSUser.h
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KSBookmark, KSTrip;

@interface KSUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * secondaryPhone;
@property (nonatomic, retain) NSNumber * customerType;
@property (nonatomic, retain) NSSet *bookmarks;
@property (nonatomic, retain) NSSet *trips;
@end

@interface KSUser (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(KSBookmark *)value;
- (void)removeBookmarksObject:(KSBookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

- (void)addTripsObject:(KSTrip *)value;
- (void)removeTripsObject:(KSTrip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
