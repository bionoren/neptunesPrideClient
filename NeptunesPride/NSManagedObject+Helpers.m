//
//  NSManagedObject+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "NSManagedObject+Helpers.h"
#import "AppDelegate.h"
#import "Player+Helpers.h"
#import "Star+Helpers.h"
#import "Fleet+Helpers.h"
#import "Research.h"
#import "Game+Helpers.h"

static NSTimer *updateTimer = nil;
static BOOL oneShotTimer = NO;

@implementation NSManagedObject (Helpers)

+(void)reset {
    [updateTimer invalidate];
    updateTimer = nil;
}

+(void)resetAndLoad {
    [self reset];
    [self loadData];
    [self loadShareData];
}

+(void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //game
        __block NSString *gameCookie;
        __block NSString *gameNumber;
        __block float tickRate;
        [GET_CONTEXT performBlockAndWait:^{
            Game *game = [Game game];
            if(!game.cookie.length || !game.number.length) {
                [self reset];
                return;
            }
            gameCookie = game.cookie;
            gameNumber = game.number;
            tickRate = game.tickRate.floatValue;
        }];

        if(oneShotTimer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                updateTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(tickRate * 60) target:self selector:@selector(loadData) userInfo:nil repeats:YES];
            });
            oneShotTimer = NO;
        }

        //curl "http://triton.ironhelmet.com/grequest/order" --data "type=order&order=full_universe_report&game_number=1429278"
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://triton.ironhelmet.com/grequest/order"]];
        [request setHTTPMethod:@"POST"];

        [request setValue:[NSString stringWithFormat:@"ACSID=%@", gameCookie] forHTTPHeaderField:@"Cookie"];

        NSString *post =[NSString stringWithFormat:@"type=order&order=full_universe_report&game_number=%@", gameNumber];
        [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];

        __block NSDictionary *data = nil;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSURLResponse *response;
            NSError *err = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            if(err) {
                NSLog(@"ERROR: %@", err);
            }

            err = nil;
            data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"report"];
            if(err) {
                NSLog(@"ERROR: %@", err);
            }
        });
        //NSLog(@"Data = %@", data);

        //update game
        if([data[@"player_uid"] intValue] < 0) {
            [self reset];
            gameCookie = nil;
            SAVE_CONTEXT;
            return;
        }

        [GET_CONTEXT performBlock:^{
            Game *game = [Game game];

            NSLog(@"Loading data...");
            game.tickRate = @([data[@"tick_rate"] floatValue]);
            game.starsForVictory = @([data[@"stars_for_victory"] intValue]);
            game.startTime = [NSDate dateWithTimeIntervalSince1970:[data[@"start_time"] longValue] / 1000];
            game.tradeCost = @([data[@"trade_cost"] floatValue]);
            game.productionRate = @([data[@"production_rate"] floatValue]);
            game.economyCost = @([data[@"dev_cost_economy"] floatValue]);
            game.industryCost = @([data[@"dev_cost_industry"] floatValue]);
            game.scienceCost = @([data[@"dev_cost_science"] floatValue]);
            game.fleetSpeed = @([data[@"fleet_speed"] floatValue]);
            SAVE_CONTEXT;

            //report
            Report *report = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:GET_CONTEXT];
            report.collectionTime = [NSDate date];
            report.gameTime = [NSDate dateWithTimeIntervalSince1970:[data[@"now"] longValue] / 1000];
            report.originatorUID = @([data[@"player_uid"] intValue]);
            report.tick = @([data[@"tick"] intValue]);
            report.tick_fragment = @([data[@"tick_fragment"] floatValue]);
            report.game = game;

            //players
            NSAssert([data[@"players"] count] > 0, @"No players??");
            for(NSDictionary *player in [data[@"players"] objectEnumerator]) {
                Player *p = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
                p.uid = @([player[@"uid"] intValue]);
                p.name = player[@"alias"];
                p.economy = @([player[@"total_economy"] intValue]);
                p.industry = @([player[@"total_industry"] intValue]);
                p.science = @([player[@"total_science"] intValue]);
                p.ships = @([player[@"total_strength"] intValue]);
                p.numFleets = @([player[@"total_fleets"] intValue]);
                p.report = report;
                p.cash = @([player[@"cash"] intValue]);
                NSAssert(p.name, @"Need a name: %@", player);

                //research
                for(NSString *name in [player[@"tech"] keyEnumerator]) {
                    NSDictionary *research = player[@"tech"][name];
                    Research *r = [NSEntityDescription insertNewObjectForEntityForName:@"Research" inManagedObjectContext:GET_CONTEXT];
                    r.name = name;
                    r.player = p;
                    r.level = @([research[@"level"] floatValue]);
                    r.value = @([research[@"value"] floatValue]);
                    if(player[@"cash"]) { //this is us
                        /*
                         There are two values "bv" and "sv" in the JSON that are not well understood.
                         bv is 1 and sv is 0 for every research but propulsion and scanning. Also, neither changes for weapons when weapons is researched
                         Initially, it is true that "bv + sv = value", but the weapons data forces us to re-evaluate this to "bv * level + sv = value"
                         This would mean that "sv" is a "base value" and "bv" is the "research increment"
                         */
                        r.increment = @([research[@"bv"] floatValue]);
                        r.goal = @([research[@"brr"] intValue]); //this doesn't get incremented in the JSON
                        r.progress = @([research[@"research"] intValue]);
                    }
                }
            }
            Player *noPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
            noPlayer.uid = @(-1);
            noPlayer.name = @"Nobody";
            noPlayer.report = report;

            //stars
            NSAssert([data[@"stars"] count] > 0, @"No stars??");
            for(NSDictionary *star in [data[@"stars"] objectEnumerator]) {
                Star *s = [NSEntityDescription insertNewObjectForEntityForName:@"Star" inManagedObjectContext:GET_CONTEXT];
                s.name = star[@"n"];
                s.x = @([star[@"x"] floatValue]);
                s.y = @([star[@"y"] floatValue]);
                s.uid = @([star[@"uid"] intValue]);
                int player = [star[@"puid"] intValue];
                s.player = [Player playerFromUID:player inReport:report];
                s.visible = @([star[@"v"] boolValue]);
                if(s.visible) {
                    s.economy = @([star[@"e"] intValue]);
                    s.industry = @([star[@"i"] intValue]);
                    s.science = @([star[@"s"] intValue]);
                    s.garrison = @([star[@"g"] intValue]);
                    s.naturalResources = @([star[@"nr"] intValue]);
                    s.ships = @([star[@"st"] intValue]);
                }
            }

            //fleets
            for(NSDictionary *fleet in [data[@"fleets"] objectEnumerator]) {
                Fleet *f = [NSEntityDescription insertNewObjectForEntityForName:@"Fleet" inManagedObjectContext:GET_CONTEXT];
                f.name = fleet[@"n"];
                int player = [fleet[@"puid"] intValue];
                f.player = [Player playerFromUID:player inReport:report];
                f.ships = @([fleet[@"st"] intValue]);
                f.uid = @([fleet[@"uid"] intValue]);
                f.x = @([fleet[@"x"] floatValue]);
                f.y = @([fleet[@"y"] floatValue]);
                if(fleet[@"ouid"]) {
                    int uid = [fleet[@"ouid"] intValue];
                    f.orbiting = [Star starFromUID:uid inReport:report];
                } else {
                    NSArray *waypoints = fleet[@"p"];
                    NSMutableOrderedSet *wp = [[NSMutableOrderedSet alloc] init];
                    for(NSNumber *waypoint in waypoints) {
                        [wp addObject:[Star starFromUID:waypoint.intValue inReport:report]];
                    }
                    f.waypoints = wp;
                }
            }
            SAVE_CONTEXT;

            [self loadDataFromShares];

            [Report setLatestReport:report];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil userInfo:nil];
            });

            NSTimeInterval timeToNextPossibleUpdate = [report timeToPossibleUpdate];
            if(!updateTimer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateTimer = [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate target:self selector:@selector(loadData) userInfo:nil repeats:NO];
                });
                oneShotTimer = YES;
            }

            [report push];
        }];
    });
}

+(void)loadDataFromShares {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        //game
        __block NSString *gameCookie;
        __block NSString *gameNumber;
        __block NSString *syncServer;
        [GET_CONTEXT performBlockAndWait:^{
            Game *game = [Game game];
            if(!game.cookie.length || !game.number.length) {
                [self reset];
                return;
            }
            gameCookie = game.cookie;
            gameNumber = game.number;
            syncServer = game.syncServer;
        }];
        data[@"ACSID"] = gameCookie;
        data[@"game"] = gameNumber;
        data[@"action"] = @"pull";

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

        err = nil;
        NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"report"];
        if(err) {
            NSLog(@"ERROR: %@", err);
        }

        //stars
        for(NSDictionary *star in jsondata[@"stars"]) {
            NSNumber *uid = star[@"uid"];
            NSNumber *tick = star[@"tick"];
            Report *report = [Report reportForTick:tick];
            Star *s = [Star starFromUID:uid.intValue inReport:report];
            if(s.visible.boolValue) {
                continue;
            } else {
                s.visible = @(YES);
                s.economy = @([star[@"economy"] intValue]);
                s.industry = @([star[@"industry"] intValue]);
                s.science = @([star[@"science"] intValue]);
                s.garrison = @([star[@"garrison"] intValue]);
                s.naturalResources = @([star[@"naturalResources"] intValue]);
                s.ships = @([star[@"ships"] intValue]);
            }
        }

        //fleets
        for(NSDictionary *fleet in jsondata[@"fleets"]) {
            NSNumber *uid = fleet[@"uid"];
            NSNumber *tick = fleet[@"tick"];
            Report *report = [Report reportForTick:tick];
            Fleet *f = [Fleet fleetFromUID:uid.intValue inReport:report];
            if(!f) {
                f.name = fleet[@"name"];
                int player = [fleet[@"puid"] intValue];
                f.player = [Player playerFromUID:player inReport:report];
                f.ships = @([fleet[@"ships"] intValue]);
                f.uid = @([fleet[@"uid"] intValue]);
                f.x = @([fleet[@"x"] floatValue]);
                f.y = @([fleet[@"y"] floatValue]);
                if(fleet[@"orbitinguid"]) {
                    int uid = [fleet[@"orbitinguid"] intValue];
                    f.orbiting = [Star starFromUID:uid inReport:report];
                } else {;
                    NSOrderedSet *wp = [[NSOrderedSet alloc] initWithObject:[Star starFromUID:[fleet[@"destuid"] intValue] inReport:report]];
                    f.waypoints = wp;
                }
            }
        }

        SAVE_CONTEXT;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil userInfo:nil];
        });
    });
}

+(void)loadShareData {
    [GET_CONTEXT performBlock:^{
        Game *game = [Game game];
        if(!game.syncServer.length) {
            return;
        }
        NSString *syncServer = game.syncServer;
        NSString *cookie = game.cookie;
        NSString *number = game.number;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            data[@"ACSID"] = cookie;
            data[@"game"] = number;
            data[@"action"] = @"shares";

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

            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadShares" object:nil userInfo:nil];
        });
    }];
}

@end