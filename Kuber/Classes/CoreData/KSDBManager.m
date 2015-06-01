//
//  KSDBManager.m
//  Kuber
//
//  Created by Asif Kamboh on 5/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//
//  Depedency on MagicalRecord
//

#import "KSDBManager.h"

#import "KSUser.h"
#import "CoreData+MagicalRecord.h"

@implementation KSDBManager

+ (instancetype)instance {
    static KSDBManager *_instance = nil;
    static dispatch_once_t dispatchQueueToken;

    dispatch_once(&dispatchQueueToken, ^{
        _instance = [[KSDBManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // TODO: Add custom init code
    }
    return self;
}

+ (void)saveContext {

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}


@end
