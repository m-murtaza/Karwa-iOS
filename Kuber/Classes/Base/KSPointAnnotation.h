//
//  KSPointAnnotation.h
//  Kuber
//
//  Created by Asif Kamboh on 6/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KSPointAnnotation : MKPointAnnotation

@property (nonatomic) BOOL isInvalid;

- (BOOL)isValid;

@end
