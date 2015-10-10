//
//  ABManager.h
//  Kuber
//
//  Created by Asif Kamboh on 10/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABManager : NSObject

- (void) fetchUserPhoneNumber;

+(NSString*) userPhoneNumber;
@end
