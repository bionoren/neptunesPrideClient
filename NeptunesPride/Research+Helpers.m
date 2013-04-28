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

+(int)levelForResearch:(const NSString*)research forPlayer:(Player*)player {
    return [self research:research forPlayer:player].level.intValue;
}

+(float)valueForResearch:(const NSString*)research forPlayer:(Player*)player {
    return [self research:research forPlayer:player].value.floatValue;
}

+(Research*)research:(const NSString*)research forPlayer:(Player*)player {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Research"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player = %@ AND name = %@", player, research];
    NSError *err = nil;
    NSArray *results = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR getting research: %@", err);
    }
    //NSAssert(results.count == 1, @"Not the results we expected for player %@ and string %@: %@", player, research, results);
    if(results.count == 0) {
        return nil;
    }
    return results[0];
}

@end