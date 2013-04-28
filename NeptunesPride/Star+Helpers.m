//
//  Star+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Star+Helpers.h"
#import "AppDelegate.h"
#import "Fleet.h"
#import "Research+Helpers.h"
#import "Player.h"

@implementation Star (Helpers)

+(NSArray*)allStarsInReport:(Report*)report {
    if(!report) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Star"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player.report = %@", report];
    NSError *err = nil;
    NSArray *ret = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    NSAssert(ret.count == 62, @"Found %ld stars in report %@?", ret.count, report);
    return ret;
}

+(NSArray*)dataForReport:(Report*)report {
    NSMutableArray *ret = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Star"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player.report = %@ AND player.uid != %@", report, report.originatorUID];
    NSError *err = nil;
    NSArray *stars = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }

    for(Star *star in stars) {
        NSMutableDictionary *s = [[NSMutableDictionary alloc] init];
        s[@"uid"] = star.uid;
        s[@"economy"] = star.economy;
        s[@"garrison"] = star.garrison;
        s[@"industry"] = star.industry;
        s[@"naturalResources"] = star.naturalResources;
        s[@"science"] = star.science;
        s[@"ships"] = star.ships;

        [ret addObject:s];
    }

    return ret;
}

+(Star*)starFromUID:(int)uid inReport:(Report*)report {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Star"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %d AND player.report = %@", uid, report];
    NSError *err = nil;
    NSArray *result = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR getting star from UID: %@", err);
        return nil;
    }
    if(result.count == 0) {
        return nil;
    }
    return result[0];
}

-(NSNumber*)numFleets {
    return @(0);
}

-(int)allShips {
    int ret = self.ships.intValue;
    for(Fleet *fleet in self.fleets) {
        ret += fleet.ships.intValue;
    }

    return ret;
}

-(NSNumber*)resources {
    if(self.player.uid.intValue < 0 || self.naturalResources.intValue == 0) {
        return @(0);
    }
    float terraforming = [Research valueForResearch:TERRAFORMING forPlayer:self.player];
    return @(self.naturalResources.intValue + terraforming * 5);
}

@end