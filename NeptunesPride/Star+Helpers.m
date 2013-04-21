//
//  Star+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Star+Helpers.h"
#import "AppDelegate.h"

@implementation Star (Helpers)

+(NSArray*)allStarsInReport:(Report*)report {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Star"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player.report = %@", report];
    NSError *err = nil;
    NSArray *ret = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    NSAssert(ret.count == 62, @"Found %ld stars?", ret.count);
    return ret;
}

@end