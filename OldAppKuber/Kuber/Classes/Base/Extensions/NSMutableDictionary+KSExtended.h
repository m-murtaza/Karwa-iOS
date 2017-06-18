//
//  NSMutableDictionary+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/17/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (KSExtended)

// Sets dictionary object, only if the obj is not nil
- (void)setObjectOrNothing:(id)anObject forKey:(id<NSCopying>)aKey;

// Sets dictionary object, only if the obj is not nil, otherwise sets the default object for the given key.
// It does nothing if the default obj is also nil
- (void)setObjectOrDefault:(id)anObject forKey:(id<NSCopying>)aKey default:(id)defaultObj;

@end

