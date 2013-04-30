//
//  Game+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Game+Helpers.h"
#import "AppDelegate.h"

static Game *game = nil;

@implementation Game (Helpers)

+(Game*)game {
    if(game) {
        return game;
    }

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    NSArray *games = FETCH(fetchRequest);
    NSAssert(games.count <= 1, @"Didn't expect so many games... %@", games);
    if(games.count == 0) {
        game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:GET_CONTEXT];
        SAVE_CONTEXT;
    } else {
        game = games[0];
    }

    return game;
}

@end