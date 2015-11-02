//
//  KSSafeArray.m
//  Kuber
//
//  Created by Asif Kamboh on 11/1/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSSafeArray.h"

@implementation KSSafeArray

- (id)objectAtIndex:(NSUInteger)index
{
    if (self.count > index) {
        return [super objectAtIndex:index];
    }
    else
    {
        @throw [NSException exceptionWithName:@"Array Out of Bound"
                                       reason:[NSString stringWithFormat:@"%lu is out of Bounds,Array Size = %lu",(unsigned long)index,(unsigned long)self.count]
                                     userInfo:nil];
    }
    return nil;
}

@end
