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
    NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"");
    if(!latestReport) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"collectionTime" ascending:NO]];
        fetchRequest.fetchLimit = 1;
        NSArray *result = FETCH_MAIN(fetchRequest);
        if(result.count == 0) {
            return nil;
        }
        NSAssert(result.count == 1, @"Not the reports we expected: %@", result);
        latestReport = result[0];
    }
    return latestReport;
}

-(void)setLatest {
    latestReport = (Report*)[GET_MAIN_CONTEXT objectWithID:self.objectID];
}

+(Report*)reportForTick:(NSNumber*)tick {
    NSManagedObjectContext *context = [[NSThread currentThread] isEqual:[NSThread mainThread]] ? GET_MAIN_CONTEXT : GET_CONTEXT;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"tick = %@", tick];
    NSArray *result = FETCH_REQUEST(fetchRequest, context);
    if(result.count == 0) {
        return nil;
    }
    return result[0];
}

-(NSTimeInterval)timeToPossibleUpdate {
    Game *game = [Game game];

    //tick_fragment is a percentage of the hour (well, there's a tick interval, but it's 60 for me)
    double minutes;
    int seconds = (int)roundf(modf(self.tick_fragment.floatValue * game.tickRate.floatValue, &minutes) * 60);
    //NSLog(@"%d minutes, %d seconds", minutes, seconds);
    return game.tickRate.floatValue * 60 - minutes * seconds;
}

-(void)push {
    [GET_CONTEXT performBlock:^{
        Report *backgroundReport = (Report*)[GET_CONTEXT objectWithID:self.objectID];
        Game *game = [Game game];
        if(!game.syncServer.length) {
            return;
        }
        NSString *syncServer = game.syncServer;

        id starData = [Star dataForReport:backgroundReport];
        id fleetData = [Fleet dataForReport:backgroundReport];

        NSNumber *gameTime = @([backgroundReport.gameTime timeIntervalSince1970]);
        NSNumber *tick = backgroundReport.tick;
        NSNumber *tick_fragment = backgroundReport.tick_fragment;

        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"cookie"] = game.cookie;
        data[@"game"] = game.number;
        data[@"action"] = @"push";

        data[@"data"] = @[starData, fleetData];
        data[@"gameTime"] = gameTime;
        data[@"tick"] = tick;
        data[@"tickFragment"] = tick_fragment;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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

-(void)pull {
    [GET_CONTEXT performBlockAndWait:^{
        Report *backgroundReport = (Report*)[GET_CONTEXT objectWithID:self.objectID];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        Game *game = [Game game];
        if(!game.cookie.length || !game.number.length || !game.syncServer.length) {
            return;
        }
        NSString *syncServer = game.syncServer;

        if(!game.cookie) {
            return;
        }
        data[@"ACSID"] = game.cookie;
        data[@"game"] = game.number;
        data[@"action"] = @"pull";
        data[@"tick"] = backgroundReport.tick;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:syncServer]];
            [request setHTTPMethod:@"POST"];
            NSError *err = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
            if(err) {
                NSLog(@"ERROR prepping pull data: %@", err);
            }
            NSString *post = [NSString stringWithFormat:@"data=%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
            [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
            //NSLog(@"JSON = %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);

            NSURLResponse *response;
            err = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            if(err) {
                NSLog(@"ERROR fetching pull data: %@", err);
                return;
            }
            NSLog(@"response = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);

            err = nil;
            NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
            if(err) {
                NSLog(@"ERROR parsing pull json: %@", err);
                return;
            }
        });
    }];
}

@end