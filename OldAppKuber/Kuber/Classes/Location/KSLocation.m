//
//  KSLocation.m
//  Kuber
//
//  Created by Asif Kamboh on 11/10/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import "KSLocation.h"

@implementation KSLocation

-(instancetype) initWithLandmark:(NSString*)landmark location:(CLLocationCoordinate2D)location Hint:(NSString*)hint
{
    self = [super init];
    if (self) {
        self.landmark = landmark;
        self.location = location;
        self.hint = hint;
    }
    return self;
}

@end
