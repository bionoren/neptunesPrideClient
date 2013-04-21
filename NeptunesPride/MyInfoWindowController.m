//
//  MyInfoWindowController.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/18/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MyInfoWindowController.h"
#import "AppDelegate.h"
#import "Player+Helpers.h"
#import "Report+Helpers.h"
#import "Star+Helpers.h"

@interface MyInfoWindowController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) NSArray *players;

@end

@implementation MyInfoWindowController

- (id)init {
    if(self = [super initWithWindowNibName:@"MyInfoWindowController"]) {
    }
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];

    [self reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [self reloadData];
}

-(void)reloadData {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"gameTime" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    NSError *err = nil;
    Report *report = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err][0];
    self.players = [report.players array];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
}

#pragma mark - NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if(item == nil) {
        return self.players[index];
    }
    if([item isKindOfClass:[Player class]]) {
        return [[[[item stars] array] sortedArrayUsingDescriptors:outlineView.sortDescriptors] objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if([item isKindOfClass:[Player class]]) {
        return YES;
    };
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if(item == nil) {
        return self.players.count;
    }
    if([item isKindOfClass:[Player class]]) {
        return [item stars].count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if([item isKindOfClass:[Player class]]) {
        if([tableColumn.identifier isEqualToString:@"name"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).name;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"economy"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).economy.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"industry"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).industry.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"science"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).science.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"fleets"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).numFleets.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"resources"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).resources.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"ships"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Player*)item).strength.stringValue;
            return ret;
        }
    } else if([item isKindOfClass:[Star class]]) {
        if([tableColumn.identifier isEqualToString:@"name"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).name;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"economy"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).economy.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"industry"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).industry.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"science"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).science.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"fleets"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = @"?";
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"resources"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).resources.stringValue;
            return ret;
        } else if([tableColumn.identifier isEqualToString:@"ships"]) {
            NSTextFieldCell *ret = [[NSTextFieldCell alloc] init];
            [ret setEditable:NO];
            [ret setSelectable:NO];
            ret.stringValue = ((Star*)item).ships.stringValue;
            return ret;
        }
    }
    return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSAssert(outlineView.sortDescriptors.count > 0, @"What? No sorts?");
    self.players = [self.players sortedArrayUsingDescriptors:outlineView.sortDescriptors];
    [outlineView reloadData];
}

@end