//
//  Player+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Player.h"

@interface Player (Helpers)

+(Player*)playerFromUID:(int)uid;
-(NSColor*)color;
-(NSNumber*)resources;
-(NSNumber*)ships;

@end