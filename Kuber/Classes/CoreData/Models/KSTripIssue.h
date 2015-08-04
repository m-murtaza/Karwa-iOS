//
//  KSTripIssue.h
//  Kuber
//
//  Created by Asif Kamboh on 8/4/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KSTripIssue : NSManagedObject

@property (nonatomic, retain) NSString * issueKey;
@property (nonatomic, retain) NSString * valueEN;
@property (nonatomic, retain) NSString * valueAR;

@end
