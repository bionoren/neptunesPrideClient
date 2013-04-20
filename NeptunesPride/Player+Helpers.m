//
//  Player+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Player+Helpers.h"
#import "AppDelegate.h"
#import "Star.h"
#import "Fleet.h"

#define RGB(r, g, b) [NSColor colorWithSRGBRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation Player (Helpers)

+(Player*)playerFromUID:(int)uid {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Player"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %d", uid];
    NSError *err = nil;
    NSArray *result = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    NSAssert(result.count > 0, @"Huh? No results for uid %d", uid);
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
            return [NSColor blackColor];
    }
    /*.pc_0 {color: rgba(0, 0, 255, 1)}
    .pc_1 {color: rgba(0, 159, 223, 1)}
    .pc_2 {color: rgba(64, 192, 0, 1)}
    .pc_3 {color: rgba(255, 192, 0, 1)}
    .pc_4 {color: rgba(223, 95, 0, 1)}
    .pc_5 {color: rgba(192, 0, 0, 1)}
    .pc_6 {color: rgba(192, 0, 192, 1)}
    .pc_7 {color: rgba(96, 0, 128, 1)}
    .pc_8 {color: rgba(0, 0, 128, 1)}
    .pc_9 {color: rgba(32, 64, 32, 1)}*/
}

-(NSNumber*)resources {
    int ret = 0;
    for(Star *star in self.stars) {
        ret += star.naturalResources.intValue;
    }

    return @(ret);
}

-(NSNumber*)ships {
    int ret = 0;
    for(Star *star in self.stars) {
        ret += star.ships.intValue;
    }
    for(Fleet *fleet in self.fleets) {
        ret += fleet.strength.intValue;
    }

    return @(ret);
}

@end