//
//  Game+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Game+Helpers.h"
#import "AppDelegate.h"

@implementation Game (Helpers)

+(Game*)game {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    NSError *err = nil;
    NSArray *games = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    NSAssert(games.count <= 1, @"Didn't expect so many games... %@", games);
    Game *ret = nil;
    if(games.count == 0) {
        ret = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:GET_CONTEXT];
        SAVE_CONTEXT;
    } else {
        ret = games[0];
    }

    return ret;
}

@end