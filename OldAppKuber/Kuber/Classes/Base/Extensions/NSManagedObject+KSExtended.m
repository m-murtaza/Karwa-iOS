//
//  NSManagedObject+KSExtended.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSManagedObject+KSExtended.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation NSManagedObject (KSExtended)

+ (instancetype)objWithValue:(id)value forAttrib:(NSString *)attrib {
    NSManagedObject *obj = [self MR_findFirstByAttribute:attrib withValue:value];
    if (!obj) {
        obj = [self MR_createEntity];
        [obj setValue:value forKey:attrib];
    }
    return obj;
}

@end

