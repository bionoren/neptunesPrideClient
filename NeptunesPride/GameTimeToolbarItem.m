//
//  GameTimeToolbarItem.m
//  NeptunesPride
//
//  Created by Bion Oren on 5/1/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "GameTimeToolbarItem.h"
#import "Game+Helpers.h"

@implementation GameTimeToolbarItem

-(void)reloadData {
    int time = (self.report.tick.intValue + self.report.tick_fragment.floatValue) * [Game game].tickRate.floatValue;
    int days = time / (24 * 60);
    int hours = (time % (24 * 60)) / (60);
    self.label = [NSString stringWithFormat:@"Game Time: %d days, %d hours", days, hours];
    self.visibilityPriority = NSToolbarItemVisibilityPriorityUser;
}

-(void)setReport:(Report *)report {
    _report = report;
    [self reloadData];
}

@end