//
//  KSLocation.h
//  Kuber
//
//  Created by Asif Kamboh on 11/10/15.
//  Copyright © 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSLocation : NSObject

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString * landmark;
@property (nonatomic, strong) NSString * hint;


-(instancetype) initWithLandmark:(NSString*)landmark location:(CLLocationCoordinate2D)location Hint:(NSString*)hint;
@end
