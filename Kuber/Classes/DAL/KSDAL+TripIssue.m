//
//  KSDAL+TripIssue.m
//  Kuber
//
//  Created by Asif Kamboh on 8/25/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+TripIssue.h"

#import <MagicalRecord/MagicalRecord.h>
#import "KSTripIssue.h"
#import "KSDBManager.h"

@implementation KSDAL (TripIssue)

+(NSArray*) allIssueList
{
    NSArray *issues = [KSTripIssue MR_findAllSortedBy:@"issueId" ascending:YES];
    return issues;
}


+ (void)syncIssueListWithCompletion:(KSDALCompletionBlock)completionBlock
{
    NSString *uri = @"/rate/meta";
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:uri params:nil completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if (KSAPIStatusSuccess == status) {
            
            NSArray *issues = response[@"data"];
            [KSDBManager saveIssuesData:issues];
            completionBlock(status,nil);
        }
    }];
}
@end
