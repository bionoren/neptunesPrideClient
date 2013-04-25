//
//  PreferencesWindowController.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "NSManagedObject+Helpers.h"
#import "Game+Helpers.h"
#import "AppDelegate.h"
#import "Game+Helpers.h"
#import "Player+Helpers.h"
#import "Report+Helpers.h"

@interface PreferencesWindowController () <NSTableViewDataSource, NSTableViewDelegate>

//settings
@property (weak) IBOutlet NSView *settingsView;
@property (weak) IBOutlet NSTextField *gameNumberField;
@property (weak) IBOutlet NSTextField *cookieField;
@property (weak) IBOutlet NSTextField *shareServerField;
@property (weak) IBOutlet NSTextField *lastSyncLabel;

//sharing
@property (weak) IBOutlet NSScrollView *sharingView;
@property (weak) IBOutlet NSTableView *playerTable;
@property (nonatomic, strong) NSOrderedSet *players;
@property (nonatomic, assign) int currentPlayer;

@end

@implementation PreferencesWindowController

-(id)init {
    if(self = [super initWithWindowNibName:@"PreferencesWindowController"]) {
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadData" object:nil];
    [self.sharingView setHidden:YES];

    Game *game = [Game game];
    if(game.number) {
        self.gameNumberField.stringValue = game.number;
    }
    if(game.cookie) {
        self.cookieField.stringValue = game.cookie;
    }
    if(game.syncServer) {
        self.shareServerField.stringValue = game.syncServer;
    }

    [self reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

-(IBAction)reloadData:(id)sender {
    [NSManagedObject resetAndLoad];
    [self reloadData];
}

-(void)reloadData {
    self.players = [Report latestReport].players;
    [self.playerTable reloadData];
}

#pragma mark - Settings

- (IBAction)showSettings:(id)sender {
    [self.sharingView setHidden:YES];
    [self.settingsView setHidden:NO];
}

- (IBAction)showSharing:(id)sender {
    [self.sharingView setHidden:NO];
    [self.settingsView setHidden:YES];
}

- (IBAction)gameUpdated:(NSTextField*)sender {
    BOOL update = ![[Game game].number isEqualToString:sender.stringValue];
    [Game game].number = sender.stringValue;
    if(update) {
        SAVE_CONTEXT;
        [NSManagedObject resetAndLoad];
    }
}

- (IBAction)cookieUpdated:(NSTextField*)sender {
    BOOL update = ![[Game game].cookie isEqualToString:sender.stringValue];
    [Game game].cookie = sender.stringValue;
    if(update) {
        SAVE_CONTEXT;
        [NSManagedObject resetAndLoad];
    }
}

- (IBAction)syncServerUpdated:(NSTextField*)sender {
    BOOL update = ![[Game game].syncServer isEqualToString:sender.stringValue];
    [Game game].syncServer = sender.stringValue;
    if(update) {
        SAVE_CONTEXT;
        [NSManagedObject resetAndLoad];
    }
}

#pragma mark - Sharing

-(IBAction)buttonDown:(id)sender {
    Player *player = [self.players objectAtIndex:self.currentPlayer];
    int status = player.shareStatus.intValue;
    if(status == OFFERED) {
        player.shareStatus = @(ACCEPTED);
    } else if(status == NONE) {
        player.shareStatus = @(OFFERING);
    } else {
        player.shareStatus = @(NONE);
    }
    SAVE_CONTEXT;
    [self reloadData];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.players.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if([aTableColumn.identifier isEqualToString:@"share"]) {
        int status = [[self.players[rowIndex] shareStatus] intValue];
        if(status >= OFFERING) {
            return @(YES);
        }
        return @(NO);
    } else if([aTableColumn.identifier isEqualToString:@"status"]) {
        switch([[self.players[rowIndex] shareStatus] intValue]) {
            case NONE:
                return @(0);
            case OFFERED:
                return @(1);
            case OFFERING:
                return @(1);
            case ACCEPTED:
                return @(2);
        }
    } else if([aTableColumn.identifier isEqualToString:@"player"]) {
        return [self.players[rowIndex] name];
    } else if([aTableColumn.identifier isEqualToString:@"lastUpdated"]) {
        NSDate *date = [self.players[rowIndex] lastSync];
        if(date) {
            return date;
        } else {
            return @"Never";
        }
    }
    return nil;
}

#pragma mark NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    self.currentPlayer = rowIndex;
    return YES;
}

@end