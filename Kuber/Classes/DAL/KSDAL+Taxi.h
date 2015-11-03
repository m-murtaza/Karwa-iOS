//
//  KSDAL+Taxi.h
//  Kuber
//
//  Created by Asif Kamboh on 10/14/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSDAL.h"

@interface KSDAL (Taxi)

+(void) trackTaxiWithTaxiNo:(NSString*)taxiNo JobID:(NSString*)jobId completion:(KSDALCompletionBlock)completionBlock;
@end
