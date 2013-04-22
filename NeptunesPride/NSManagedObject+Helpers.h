//
//  NSManagedObject+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Report+Helpers.h"

@interface NSManagedObject (Helpers)

+(Report*)loadData;
+(void)deleteAllObjects;
+(void)resetAndLoad;

@end