//
//  Research+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Research+Helpers.h"
#import "AppDelegate.h"
#import "Player.h"

const NSString *BANKING = @"banking";
const NSString *MANUFACTURING = @"manufacturing";
const NSString *HYPERSPACE = @"propulsion";
const NSString *GENERAL = @"research";
const NSString *SCANNING = @"scanning";
const NSString *TERRAFORMING = @"terraforming";
const NSString *WEAPONS = @"weapons";

@implementation Research (Helpers)

+(int)levelForResearch:(const NSString*)research forPlayer:(Player*)player {
    return [self research:research forPlayer:player].level.intValue;
}

+(float)valueForResearch:(const NSString*)research forPlayer:(Player*)player {
    return [self research:research forPlayer:player].value.floatValue;
}

+(Research*)research:(const NSString*)research forPlayer:(Player*)player {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Research"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"player = %@ AND name = %@", player, research];
    NSArray *results = FETCH_REQUEST(fetchRequest, player.managedObjectContext);
    //NSAssert(results.count == 1, @"Not the results we expected for player %@ and string %@: %@", player, research, results);
    if(results.count == 0) {
        return nil;
    }
    return results[0];
}

@end