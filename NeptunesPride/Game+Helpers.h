//
//  Game+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Game.h"

@interface Game (Helpers)

+(Game*)game;

//MUST be called from the main thread
+(void)loadData;
-(void)resetAndLoad;

+(void)loadShareData;

@end