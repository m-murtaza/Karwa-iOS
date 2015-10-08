//
//  KSDAL+Franchise.m
//  Kuber
//
//  Created by Asif Kamboh on 10/8/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+Franchise.h"
#import "KSDBManager.h"

@implementation KSDAL (Franchise)

+ (void)syncFranchiseWithCompletion:(KSDALCompletionBlock)completionBlock
{
    KSWebClient *webClient = [KSWebClient instance];
    
    [webClient GET:@"/info/franchises" params:nil completion:^(BOOL success, NSDictionary *response) {
        KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
        if(KSAPIStatusSuccess == status){
            
            NSArray *franchises = [KSDAL addFranchises:response[@"data"]];

            [KSDBManager saveContext:^{
                
                completionBlock(status, franchises);
            }];
        }
        else{
            
            completionBlock(status, nil);
        }
    }];
}

+(NSArray*) addFranchises:(NSArray*)franchises{

    NSMutableArray *franchisesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *franchise in franchises) {
        [franchisesArray addObject:[KSDAL addFranchise:franchise]];
    }
    return franchisesArray.count ? [NSArray arrayWithArray:franchisesArray] : nil;
}

+(KSFranchise*) addFranchise:(NSDictionary*)franchiseData{
    
    KSFranchise *franchise = nil;
    if(franchiseData){
        
        franchise = [KSFranchise objWithValue:franchiseData[@"FranchiseId"] forAttrib:@"franchiseId"];
        franchise.name = franchiseData[@"Name"];
        franchise.logoUrl = franchiseData[@"LogoUrl"];
    }
    return franchise;
}

@end
