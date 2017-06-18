//
//  KSDAL+Franchise.h
//  Kuber
//
//  Created by Asif Kamboh on 10/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL.h"

@interface KSDAL (Franchise)

+ (void)syncFranchiseWithCompletion:(KSDALCompletionBlock)completionBlock;
+(NSArray*) allFranchises;

@end
