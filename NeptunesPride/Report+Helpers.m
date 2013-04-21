//
//  Report+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Report+Helpers.h"
#import "AppDelegate.h"

static Report *latestReport;

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
    //tick_fragment is a percentage of the hour (well, there's a tick interval, but it's 60 for me)
    int minutes = (int)(self.tick_fragment.floatValue * 60) % 15;
    int seconds = (int)roundf((int)(self.tick_fragment.floatValue * 60 * 100) / 60.0);
    //NSLog(@"%d minutes, %d seconds", minutes, seconds);
    return 15*60 - minutes * seconds;
}

@end