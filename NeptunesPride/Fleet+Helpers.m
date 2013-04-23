//
//  Fleet+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Fleet+Helpers.h"
#import "AppDelegate.h"
#import "Player.h"
#import "Star.h"

@implementation Fleet (Helpers)

+(NSArray*)allFleetsInReport:(Report*)report {
    if(!report) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fleet"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player.report = %@", report];
    NSError *err = nil;
    NSArray *ret = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    return ret;
}

+(NSArray*)dataForReport:(Report*)report {
    NSMutableArray *ret = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fleet"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player.report = %@ AND player.uid != %@", report, report.originatorUID];
    NSError *err = nil;
    NSArray *fleets = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }

    for(Fleet *fleet in fleets) {
        NSMutableDictionary *f = [[NSMutableDictionary alloc] init];
        f[@"x"] = fleet.x;
        f[@"y"] = fleet.y;
        f[@"ships"] = fleet.ships;
        f[@"uid"] = fleet.uid;
        f[@"puid"] = fleet.player.uid;
        if(fleet.waypoints.count > 0) {
            f[@"destuid"] = [fleet.waypoints[0] uid];
        } else {
            f[@"destuid"] = @(-1);
        }
        if(fleet.orbiting) {
            f[@"orbitinguid"] = fleet.orbiting.uid;
        } else {
            f[@"orbitinguid"] = @(-1);
        }

        [ret addObject:f];
    }
    
    return ret;
}

@end