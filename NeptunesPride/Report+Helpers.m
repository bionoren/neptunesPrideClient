//
//  Report+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Report+Helpers.h"

@implementation Report (Helpers)

-(NSTimeInterval)timeToPossibleUpdate {
    //tick_fragment is a percentage of the hour (well, there's a tick interval, but it's 60 for me)
    int minutes = (int)(self.tick_fragment.floatValue * 60) % 15;
    int seconds = (int)roundf((int)(self.tick_fragment.floatValue * 60 * 100) / 60.0);
    //NSLog(@"%d minutes, %d seconds", minutes, seconds);
    return 15*60 - minutes * seconds;
}

@end