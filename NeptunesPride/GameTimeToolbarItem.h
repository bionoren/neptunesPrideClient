//
//  GameTimeToolbarItem.h
//  NeptunesPride
//
//  Created by Bion Oren on 5/1/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Report.h"

@interface GameTimeToolbarItem : NSToolbarItem

@property (nonatomic, strong) Report *report;

-(void)reloadData;

@end