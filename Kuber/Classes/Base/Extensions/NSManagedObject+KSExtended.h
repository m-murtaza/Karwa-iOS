//
//  NSManagedObject+KSExtended.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <CoreData/NSManagedObject.h>

@interface NSManagedObject (KSExtended)

+ (instancetype)objWithValue:(id)value forAttrib:(NSString *)attrib;

@end
