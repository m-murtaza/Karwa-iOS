//
//  KSDAL+TripIssue.h
//  Kuber
//
//  Created by Asif Kamboh on 8/25/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL.h"

@interface KSDAL (TripIssue)

+(NSArray*) allIssueList;

+ (void)syncIssueListWithCompletion:(KSDALCompletionBlock)completionBlock;

@end
