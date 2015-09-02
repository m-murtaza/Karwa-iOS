//
//  KSGoogleAnalytics.m
//  Kuber
//
//  Created by Asif Kamboh on 9/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSGoogleAnalytics.h"

@implementation KSGoogleAnalytics

+(void) trackPage:(NSString*)name
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
@end
