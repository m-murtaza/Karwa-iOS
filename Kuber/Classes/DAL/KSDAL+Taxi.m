//
//  KSDAL+Taxi.m
//  Kuber
//
//  Created by Asif Kamboh on 10/14/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL+Taxi.h"

@implementation KSDAL (Taxi)

+(void) trackTaxiWithTaxiNo:(NSString*)taxiNo completion:(KSDALCompletionBlock)completionBlock
{
    if (taxiNo.length == 0) {
    
        completionBlock(NO,nil);
        return;
    }
    taxiNo = [taxiNo URLEncodedString];
    
    KSWebClient *webClient = [KSWebClient instance];
    [webClient GET:[NSString stringWithFormat:@"/track/%@",taxiNo]
            params:nil
        completion:^(BOOL success, id response) {
            KSAPIStatus status = [KSDAL statusFromResponse:response success:success];
            DLog(@"%@",response);
            if(KSAPIStatusSuccess == status){
                
                KSVehicleTrackingInfo *taxiInfo = [KSVehicleTrackingInfo trackInfoWithDictionary:response[@"data"]];
                completionBlock(status,taxiInfo);
            }
            else
            {
                completionBlock(status,nil);
            }
        
        }];
}


@end
