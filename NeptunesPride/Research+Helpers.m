//
//  Research+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Research+Helpers.h"
#import "AppDelegate.h"

@implementation Research (Helpers)

+(float)valueForResearch:(const NSString*)research forPlayer:(Player*)player {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Research"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player = %@ AND name = %@", player, research];
    NSError *err = nil;
    NSArray *results = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    NSAssert(results.count == 1, @"Not the results we expected for player %@ and string %@: %@", player, research, results);
    return [[results[0] value] floatValue];
}

@end