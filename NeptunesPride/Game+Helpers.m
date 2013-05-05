//
//  Game+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Game+Helpers.h"
#import "AppDelegate.h"
#import "Report+Helpers.h"
#import "Player.h"
#import "Research+Helpers.h"
#import "Star+Helpers.h"
#import "Fleet+Helpers.h"

static Game *game = nil;
static Game *mainGame = nil;

static __strong NSTimer *updateTimer = nil;
static BOOL oneShotTimer = NO;

@implementation Game (Helpers)

+(Game*)game {
    Game *__strong *gamePtr = ([[NSThread currentThread] isEqual:[NSThread mainThread]]) ? &mainGame : &game;
    NSManagedObjectContext *context = ([[NSThread currentThread] isEqual:[NSThread mainThread]]) ? GET_MAIN_CONTEXT : GET_CONTEXT;

    if(*gamePtr) {
        return *gamePtr;
    }

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    NSArray *games = FETCH_REQUEST(fetchRequest, context);
    NSAssert(games.count <= 1, @"Didn't expect so many games... %@", games);
    if(games.count == 0) {
        *gamePtr = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
        SAVE(context);
    } else {
        *gamePtr = games[0];
    }

    return *gamePtr;
}

#pragma mark - Data Loading

-(void)reset {
    [updateTimer invalidate];
    updateTimer = nil;
}

-(void)resetAndLoad {
    [self reset];
    [Game loadData];
    [Game loadShareData];
}

+(void)loadDataFromTimer:(NSTimer*)timer {
    [self loadData];
}

+(void)loadData {
    [GET_CONTEXT performBlock:^{
        Game *game = [Game game];
        [game.managedObjectContext refreshObject:game mergeChanges:YES];

        if(!game.cookie.length || !game.number.length) {
            [game reset];
            return;
        }

        NSString *gameCookie = game.cookie;
        NSString *gameNumber = game.number;
        float tickRate = game.tickRate.floatValue;

        if(oneShotTimer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Fire faster for a more up-to-date interface
                updateTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(tickRate * 60 * 0.25) target:self selector:@selector(loadDataFromTimer:) userInfo:nil repeats:YES];
            });
            oneShotTimer = NO;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            @autoreleasepool {
                //curl "http://triton.ironhelmet.com/grequest/order" --data "type=order&order=full_universe_report&game_number=1429278"
                NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://triton.ironhelmet.com/grequest/order"]];
                [request setHTTPMethod:@"POST"];

                [request setValue:gameCookie forHTTPHeaderField:@"Cookie"];

                NSString *post =[NSString stringWithFormat:@"type=order&order=full_universe_report&game_number=%@", gameNumber];
                [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];

                NSURLResponse *response;
                NSError *err = nil;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                if(err) {
                    NSLog(@"ERROR fetching game data: %@", err);
                }
                //NSLog(@"response = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);

                err = nil;
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"report"];
                if(err) {
                    NSLog(@"ERROR parsing game data: %@", err);
                    return;
                }
                //NSLog(@"Data = %@", data);

                //update game
                [game.managedObjectContext performBlock:^{
                    if([data[@"player_uid"] intValue] < 0) {
                        [game reset];
                        game.cookie = nil;
                        SAVE(game.managedObjectContext);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[Game game].managedObjectContext refreshObject:[Game game] mergeChanges:YES];
                        });
                        NSLog(@"Looks like authentication failed");

                        NSUserNotification *notification = [[NSUserNotification alloc] init];
                        notification.title = @"Cookie Expired";
                        notification.subtitle = @"Looks like your cookies expired";
                        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                        return;
                    }

                    NSLog(@"Loading data...");
                    if(!game.tickRate) {
                        game.tickRate = @([data[@"tick_rate"] floatValue]);
                        game.starsForVictory = @([data[@"stars_for_victory"] intValue]);
                        game.startTime = [NSDate dateWithTimeIntervalSince1970:[data[@"start_time"] longValue] / 1000];
                        game.tradeCost = @([data[@"trade_cost"] floatValue]);
                        game.productionRate = @([data[@"production_rate"] floatValue]);
                        game.economyCost = @([data[@"dev_cost_economy"] floatValue]);
                        game.industryCost = @([data[@"dev_cost_industry"] floatValue]);
                        game.scienceCost = @([data[@"dev_cost_science"] floatValue]);
                        game.fleetSpeed = @([data[@"fleet_speed"] floatValue]);
                        SAVE(game.managedObjectContext);
                    }

                    //report
                    Report *lastReport;
                    int tick = [data[@"tick"] intValue];
                    while(!(lastReport = [Report reportForTick:@(--tick)]) && tick >= 0);
                    Report *report = [Report reportForTick:@([data[@"tick"] intValue])];
                    if(!report) {
                        report = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:GET_CONTEXT];
                    }
                    report.collectionTime = [NSDate date];
                    report.gameTime = [NSDate dateWithTimeIntervalSince1970:[data[@"now"] longValue] / 1000];
                    report.originatorUID = @([data[@"player_uid"] intValue]);
                    report.tick = @([data[@"tick"] intValue]);
                    report.tick_fragment = @([data[@"tick_fragment"] floatValue]);
                    report.game = game;

                    //players
                    NSAssert([data[@"players"] count] > 0, @"No players??");
                    NSMutableDictionary *players = [[NSMutableDictionary alloc] init];
                    for(NSDictionary *player in [data[@"players"] objectEnumerator]) {
                        Player *p = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
                        p.report = report;
                        p.uid = @([player[@"uid"] intValue]);
                        p.name = player[@"alias"];
                        p.economy = @([player[@"total_economy"] intValue]);
                        p.industry = @([player[@"total_industry"] intValue]);
                        p.science = @([player[@"total_science"] intValue]);
                        p.ships = @([player[@"total_strength"] intValue]);
                        p.numFleets = @([player[@"total_fleets"] intValue]);
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
                        [players setObject:p forKey:p.uid];
                    }
                    Player *noPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:GET_CONTEXT];
                    noPlayer.uid = @(-1);
                    noPlayer.name = @"Nobody";
                    noPlayer.report = report;
                    [players setObject:noPlayer forKey:noPlayer.uid];

                    //stars
                    NSAssert([data[@"stars"] count] > 0, @"No stars??");
                    NSMutableDictionary *stars = [[NSMutableDictionary alloc] init];
                    for(NSDictionary *star in [data[@"stars"] objectEnumerator]) {
                        Star *s = [NSEntityDescription insertNewObjectForEntityForName:@"Star" inManagedObjectContext:GET_CONTEXT];
                        s.report = report;
                        s.name = star[@"n"];
                        s.x = @([star[@"x"] floatValue]);
                        s.y = @([star[@"y"] floatValue]);
                        s.uid = @([star[@"uid"] intValue]);
                        int player = [star[@"puid"] intValue];
                        s.player = players[@(player)];
                        s.visible = @([star[@"v"] boolValue]);
                        if(s.visible) {
                            s.economy = @([star[@"e"] intValue]);
                            s.industry = @([star[@"i"] intValue]);
                            s.science = @([star[@"s"] intValue]);
                            s.garrison = @([star[@"g"] intValue]);
                            s.naturalResources = @([star[@"nr"] intValue]);
                            s.ships = @([star[@"st"] intValue]);
                        }
                        [stars setObject:s forKey:s.uid];
                    }

                    //fleets
                    for(NSDictionary *fleet in [data[@"fleets"] objectEnumerator]) {
                        Fleet *f = [NSEntityDescription insertNewObjectForEntityForName:@"Fleet" inManagedObjectContext:GET_CONTEXT];
                        f.report = report;
                        f.name = fleet[@"n"];
                        int player = [fleet[@"puid"] intValue];
                        f.player = players[@(player)];
                        f.ships = @([fleet[@"st"] intValue]);
                        f.uid = @([fleet[@"uid"] intValue]);
                        f.x = @([fleet[@"x"] floatValue]);
                        f.y = @([fleet[@"y"] floatValue]);
                        if(fleet[@"ouid"]) {
                            int uid = [fleet[@"ouid"] intValue];
                            f.orbiting = stars[@(uid)];
                        } else {
                            NSArray *waypoints = fleet[@"p"];
                            NSMutableOrderedSet *wp = [[NSMutableOrderedSet alloc] init];
                            for(NSNumber *waypoint in waypoints) {
                                [wp addObject:stars[waypoint]];
                            }
                            f.waypoints = wp;
                            Fleet *lastFleet = [Fleet fleetFromUID:f.uid.intValue inReport:lastReport];
                            if(![f.player.uid isEqual:report.originatorUID] && (!lastFleet || lastFleet.orbiting)) {
                                NSUserNotification *fleetLaunchNotification = [[NSUserNotification alloc] init];
                                fleetLaunchNotification.title = @"Fleet Launched";
                                fleetLaunchNotification.subtitle = [NSString stringWithFormat:@"%@'s %d ship fleet", [f.player name], f.ships.intValue];
                                Star *dest = f.waypoints[0];
                                int hours = [game ticksFromPoint:[f point] toPoint:[dest point] warpGates:NO];
                                int remainingShips = [game shipsRemainingForStar:dest attackingFleet:f];

                                if(dest.visible.boolValue && dest.player.uid.intValue != f.orbiting.player.uid.intValue) {
                                    fleetLaunchNotification.informativeText = [NSString stringWithFormat:@"%@ launched a fleet from %@ to %@ with %d ships. The fleet will arrive in %d hours. We predict the %@ will win with %d ships remaining", [f.player name], lastFleet.orbiting.name, dest.name, f.ships.intValue, hours, (remainingShips > 0)?@"defender":@"attacker", abs(remainingShips)];
                                } else {
                                    fleetLaunchNotification.informativeText = [NSString stringWithFormat:@"%@ launched a fleet from %@ to %@ with %d ships. The fleet will arrive in %d hours.", f.player.name, lastFleet.orbiting.name, dest.name, f.ships.intValue, hours];
                                }
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:fleetLaunchNotification];
                            }
                        }
                    }
                    SAVE(game.managedObjectContext);
                    
                    [report setLatest];
                    [report pull];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[Game game].managedObjectContext refreshObject:[Game game] mergeChanges:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil userInfo:nil];
                    });

                    if(!updateTimer) {
                        NSTimeInterval timeToNextPossibleUpdate = [report timeToPossibleUpdate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //NSLog(@"Next timer fires in %f seconds (%f minutes)", timeToNextPossibleUpdate, timeToNextPossibleUpdate / 60);
                            updateTimer = [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate target:self selector:@selector(loadDataFromTimer:) userInfo:nil repeats:NO];
                        });
                        oneShotTimer = YES;
                    }
                    
                    [report push];
                }];
            }
        });
    }];
}

#pragma mark - Syncing

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
                NSLog(@"ERROR loading share data: %@", err);
                return;
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

-(int)ticksFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 warpGates:(BOOL)warp {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    float distance = sqrtf(dx * dx + dy * dy);
    float time = distance / self.fleetSpeed.floatValue;
    if(warp) {
        time /= 3;
    }
    return ceilf(time);
}

///if the return value is negative, the attacker won with that many ships
-(int)shipsRemainingForStar:(Star*)star attackingFleet:(Fleet*)fleet {
    if(!star.visible.boolValue) {
        return fleet.ships.intValue;
    }
    int timeToAttack = [self ticksFromPoint:fleet.point toPoint:star.point warpGates:NO];

    int starShips = star.ships.intValue;
    for(Fleet *fleet in star.fleets) {
        starShips += fleet.ships.intValue;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fleet"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player = %@ AND %@ IN waypoints", star.player, star];
    fetchRequest.relationshipKeyPathsForPrefetching = @[@"waypoints", @"orbiting"];
    NSArray *fleets = FETCH_REQUEST(fetchRequest, star.managedObjectContext);
    for(Fleet *fleet in fleets) {
        int transitTime = fleet.orbiting ? 1 : 0;

        Star *lastStar = fleet.orbiting;
        for(Star *waypoint in fleet.waypoints) {
            if(lastStar) {
                transitTime += [self ticksFromPoint:lastStar.point toPoint:waypoint.point warpGates:NO];
            } else {
                transitTime += [self ticksFromPoint:fleet.point toPoint:waypoint.point warpGates:NO];
            }
            if([waypoint isEqual:star]) {
                break;
            }
            lastStar = waypoint;
        }
        if(transitTime <= timeToAttack) {
            starShips += fleet.ships.intValue;
        }
    }

    Research *dwr = [Research research:WEAPONS forPlayer:star.player];
    float defenderWeapons = dwr.value.floatValue + 1;
    if([WEAPONS isEqualToString:star.player.research.name]) {
        if(dwr.progress.intValue + timeToAttack * star.player.science.intValue >= dwr.goal.intValue * dwr.level.intValue) {
            defenderWeapons++;
        }
    }
    Research *awr = [Research research:WEAPONS forPlayer:fleet.player];
    float attackerWeapons = awr.value.floatValue;
    if([WEAPONS isEqualToString:fleet.player.research.name]) {
        if(awr.progress.intValue + timeToAttack * fleet.player.science.intValue >= awr.goal.intValue * awr.level.intValue) {
            attackerWeapons++;
        }
    }

    int remainingDefenderShips = starShips - attackerWeapons * (fleet.ships.intValue / defenderWeapons);
    if(remainingDefenderShips > 0) {
        return remainingDefenderShips;
    }
    //                            attacker ships      - defenderWeapons * attacker number of attacks    - defender shoots first
    int remainingAttackerShips = fleet.ships.intValue - defenderWeapons * (starShips / attackerWeapons) - defenderWeapons;
    NSAssert(remainingAttackerShips > 0, @"Something went wrong...");
    return -remainingAttackerShips;
}

@end