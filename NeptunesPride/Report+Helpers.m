//
//  Report+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Report+Helpers.h"
#import "AppDelegate.h"
#import "Game+Helpers.h"

static Report *latestReport = nil;

@implementation Report (Helpers)

+(Report*)latestReport {
    if(!latestReport) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"gameTime" ascending:NO]];
        fetchRequest.fetchLimit = 1;
        NSError *err = nil;
        NSArray *result = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
        if(err) {
            NSLog(@"ERROR: %@", err);
        }
        if(result.count == 0) {
            return nil;
        }
        NSAssert(result.count == 1, @"Not the reports we expected: %@", result);
        latestReport = result[0];
    }
    return latestReport;
}

+(void)setLatestReport:(Report*)report {
    latestReport = report;
}

-(NSTimeInterval)timeToPossibleUpdate {
    Game *game = [Game game];

    //tick_fragment is a percentage of the hour (well, there's a tick interval, but it's 60 for me)
    int minutes = (int)(self.tick_fragment.floatValue * game.tickRate.floatValue);
    int seconds = (int)roundf((int)(self.tick_fragment.floatValue * game.tickRate.floatValue * 100) / game.tickRate.floatValue);
    //NSLog(@"%d minutes, %d seconds", minutes, seconds);
    return game.tickRate.floatValue * 60 - minutes * seconds;
}

@end