//
//  Player+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Player+Helpers.h"
#import "AppDelegate.h"
#import "Star+Helpers.h"
#import "Fleet.h"
#import "Game+Helpers.h"
#import "NSManagedObject+Helpers.h"

#define RGB(r, g, b) [NSColor colorWithSRGBRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation Player (Helpers)

+(Player*)playerFromUID:(int)uid inReport:(Report*)report {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Player"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %d AND report = %@", uid, report];
    NSArray *result = FETCH(fetchRequest);
    //NSAssert(result.count > 0, @"Huh? No results for uid %d", uid);
    if(result.count == 0) {
        return nil;
    }
    return result[0];
}

-(NSColor*)color {
    switch(self.uid.intValue) {
        case 0:
            return RGB(0, 0, 255);
            break;
        case 1:
            return RGB(0, 159, 223);
            break;
        case 2:
            return RGB(64, 192, 0);
            break;
        case 3:
            return RGB(255, 192, 0);
            break;
        case 4:
            return RGB(223, 95, 0);
            break;
        case 5:
            return RGB(192, 0, 0);
            break;
        case 6:
            return RGB(192, 0, 192);
            break;
        case 7:
            return RGB(96, 0, 128);
            break;
        case 8:
            return RGB(0, 0, 128);
            break;
        case 9:
            return RGB(32, 64, 32);
            break;
        default:
            return [NSColor grayColor];
    }
}

-(NSNumber*)resources {
    int ret = 0;
    for(Star *star in self.stars) {
        ret += star.resources.intValue;
    }

    return @(ret);
}

-(NSNumber*)visibleShips {
    int ret = 0;
    for(Star *star in self.stars) {
        ret += star.ships.intValue;
    }
    for(Fleet *fleet in self.fleets) {
        ret += fleet.ships.intValue;
    }

    return @(ret);
}

-(void)share {
    Game *game = [Game game];
    if(!game.syncServer.length) {
        return;
    }
    NSString *syncServer = game.syncServer;
    NSString *cookie = game.cookie;
    NSString *number = game.number;
    NSNumber *uid = self.uid;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"ACSID"] = cookie;
        data[@"game"] = number;
        data[@"action"] = @"share";
        data[@"shareUserID"] = uid;

        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:syncServer]];
        [request setHTTPMethod:@"POST"];
        NSError *err = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
        if(err) {
            NSLog(@"ERROR preparing sharing data: %@", err);
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
        NSNumber *reload = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"reload"];
        if(err) {
            NSLog(@"ERROR parsing sharing: %@", err);
        }
        if(reload.boolValue) {
            [NSManagedObject loadData];
        }
    });
}

-(void)unshare {
    Game *game = [Game game];
    if(!game.syncServer.length) {
        return;
    }
    NSString *syncServer = game.syncServer;
    NSString *cookie = game.cookie;
    NSString *number = game.number;
    NSNumber *uid = self.uid;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"ACSID"] = cookie;
        data[@"game"] = number;
        data[@"action"] = @"unshare";
        data[@"shareUserID"] = uid;

        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:syncServer]];
        [request setHTTPMethod:@"POST"];
        NSError *err = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
        if(err) {
            NSLog(@"ERROR preparing unshare data: %@", err);
        }
        NSString *post = [NSString stringWithFormat:@"data=%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
        [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"JSON = %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);

        NSURLResponse *response;
        err = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        if(err) {
            NSLog(@"ERROR parsing unsharing: %@", err);
        }
        NSLog(@"response = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);

        [NSManagedObject loadData];
    });
}

@end