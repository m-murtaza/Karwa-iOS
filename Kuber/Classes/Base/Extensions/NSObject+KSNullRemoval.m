//
//  NSObject+KSNullRemoval.m
//  Kuber
//
//  Created by Asif Kamboh on 8/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "NSObject+KSNullRemoval.h"

@implementation NSObject (KSNullRemoval)


- (id)objectIfNotNSNull {
    
    return [NSObject removeNullsFromObj:self];
}

+ (id)removeNullsFromObj:(id)obj {
    
    id output = obj;
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        output = [self removeNullsFromDictionary:obj];
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        
        output = [self removeNullsFromArray:obj];
    }
    else if ([obj isKindOfClass:[NSNull class]]) {
        
        output = nil;
    }
    
    return output;
}

+ (NSArray *)removeNullsFromArray:(NSArray *)array {
    
    NSMutableArray *output = [NSMutableArray array];
    for (id obj in array) {
        
        id processedObj = [self removeNullsFromObj:obj];
        if (processedObj) {
            
            [output addObject:processedObj];
        }
    }
    return output;
}

+ (NSDictionary *)removeNullsFromDictionary:(NSDictionary *)dict {
    
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    
    for (NSString *key in dict.allKeys) {
        
        id processedObj = [self removeNullsFromObj:dict[key]];
        if (processedObj) {
            
            output[key] = processedObj;
        }
    }
    return [NSDictionary dictionaryWithDictionary:output];
}

@end
