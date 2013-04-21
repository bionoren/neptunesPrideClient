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

@implementation ProductionToolbarItem

-(void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];
}

-(void)reloadData:(NSNotification*)notification {
    Report *report = notification.userInfo[@"report"];
    Player *me = [Player playerFromUID:report.originatorUID.intValue inReport:report];
    int banking = (int)[Research valueForResearch:BANKING forPlayer:me];
    self.label = [NSString stringWithFormat:@"Credits: $%d [$%d]", me.cash.intValue, me.cash.intValue + me.economy.intValue * 10 + banking * 50];
    self.visibilityPriority = NSToolbarItemVisibilityPriorityUser;
}

@end