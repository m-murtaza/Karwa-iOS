//
//  NSMutableDictionary+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSMutableDictionary+KSExtended.h"

@implementation NSMutableDictionary (KSExtended)

- (void)setObjectOrNothing:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)setObjectOrDefault:(id)anObject forKey:(id<NSCopying>)aKey default:(id)defaultObj {
    if (!anObject) {
        anObject = defaultObj;
    }
    [self setObjectOrNothing:anObject forKey:aKey];
}

@end

