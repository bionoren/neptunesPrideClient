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
#import "Star+Helpers.h"
#import "Fleet+Helpers.h"

static Report *latestReport = nil;

@implementation Report (Helpers)

+(Report*)latestReport {
    if(!latestReport) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"collectionTime" ascending:NO]];
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

+(Report*)reportForTick:(NSNumber*)tick {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"tick = %@", tick];
    NSError *err = nil;
    NSArray *result = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    if(result.count == 0) {
        Report *ret = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:GET_CONTEXT];
        return ret;
    }
    return result[0];
}

-(NSTimeInterval)timeToPossibleUpdate {
    Game *game = [Game game];

    //tick_fragment is a percentage of the hour (well, there's a tick interval, but it's 60 for me)
    int minutes = (int)(self.tick_fragment.floatValue * game.tickRate.floatValue);
    int seconds = (int)roundf((int)(self.tick_fragment.floatValue * game.tickRate.floatValue * 100) / game.tickRate.floatValue);
    //NSLog(@"%d minutes, %d seconds", minutes, seconds);
    return game.tickRate.floatValue * 60 - minutes * seconds;
}

-(void)push {
    [GET_CONTEXT performBlock:^{
        Game *game = [Game game];
        if(!game.syncServer.length) {
            return;
        }
        NSString *syncServer = game.syncServer;
        NSString *cookie = game.cookie;
        NSString *number = game.number;

        id starData = [Star dataForReport:self];
        id fleetData = [Fleet dataForReport:self];

        NSNumber *gameTime = @([self.gameTime timeIntervalSince1970]);
        NSNumber *tick = self.tick;
        NSNumber *tick_fragment = self.tick_fragment;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            data[@"ACSID"] = cookie;
            data[@"game"] = number;
            data[@"action"] = @"push";
            data[@"starData"] = starData;
            data[@"fleetData"] = fleetData;
            data[@"gameTime"] = gameTime;
            data[@"tick"] = tick;
            data[@"tickFragment"] = tick_fragment;

            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:syncServer]];
            [request setHTTPMethod:@"POST"];
            NSError *err = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
            if(err) {
                NSLog(@"ERROR: %@", err);
            }
            NSString *post = [NSString stringWithFormat:@"data=%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
            [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
            //NSLog(@"JSON = %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);

            NSURLResponse *response;
            err = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            if(err) {
                NSLog(@"ERROR: %@", err);
            }
            NSLog(@"response = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        });
    }];
}

@end