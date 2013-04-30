//
//  ProductionToolbarItem.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "ProductionToolbarItem.h"
#import "Report+Helpers.h"
#import "Player+Helpers.h"
#import "Research+Helpers.h"
#import "AppDelegate.h"

@implementation ProductionToolbarItem

-(void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];
}

-(void)reloadData:(NSNotification*)notification {
    Report *report = [Report latestReport];
    Player *me = [Player playerFromUID:report.originatorUID.intValue inReport:report];
    int banking = (int)[Research valueForResearch:BANKING forPlayer:me];
    int cash = me.cash.intValue;
    int economy = me.economy.intValue;
    self.label = [NSString stringWithFormat:@"Credits: $%d [$%d]", cash, cash + economy * 10 + banking * 50];
    self.visibilityPriority = NSToolbarItemVisibilityPriorityUser;
}

@end