//
//  NSManagedObject+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "NSManagedObject+Helpers.h"
#import "AppDelegate.h"

@implementation NSManagedObject (Helpers)

+ (void) deleteAllObjects {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:GET_CONTEXT];
    [fetchRequest setEntity:entity];

    NSError *err = nil;
    NSArray *items = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }


    for (NSManagedObject *obj in items) {
    	[GET_CONTEXT deleteObject:obj];
    }
    SAVE_CONTEXT;
}

@end