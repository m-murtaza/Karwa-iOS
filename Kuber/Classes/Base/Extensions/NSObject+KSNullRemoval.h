//
//  NSObject+KSNullRemoval.h
//  Kuber
//
//  Created by Asif Kamboh on 8/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KSNullRemoval)

- (id)objectIfNotNSNull;

@end
