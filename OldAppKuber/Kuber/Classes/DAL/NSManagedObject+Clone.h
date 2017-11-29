//
//  NSManagedObject+Clone.h
//  Kuber
//
//  Created by Muhammad Usman on 11/8/17.
//  Copyright © 2017 Karwa Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Clone)

-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context withCopiedCache:(NSMutableDictionary *)alreadyCopied exludeEntities:(NSArray *)namesOfEntitiesToExclude;
-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;
-(NSManagedObject *) clone;
@end
