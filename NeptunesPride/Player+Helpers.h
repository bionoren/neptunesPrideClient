//
//  Player+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Player.h"
#import "Report.h"

typedef enum shareStatus {
    NONE,
    OFFERED,
    OFFERING,
    ACCEPTED
} shareStatus;

@interface Player (Helpers)

+(Player*)playerFromUID:(int)uid inReport:(Report*)report;
-(NSColor*)color;
-(NSNumber*)resources;
-(NSNumber*)visibleShips;

@end