//
//  PreferencesWindowController.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "PreferencesWindowController.h"
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
@property (nonatomic, strong) NSArray *players;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadShares" object:nil];
    Game *game = [Game game];
    [self.sharingView setHidden:YES];

    if(game.number.length) {
        self.gameNumberField.stringValue = game.number;
    }
    if(game.cookie.length) {
        self.cookieField.stringValue = game.cookie;
    }
    if(game.syncServer.length) {
        self.shareServerField.stringValue = game.syncServer;
    }

    [self reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

-(IBAction)reloadData:(id)sender {
    [[Game game] resetAndLoad];
    [self reloadData];
}

-(void)reloadData {
    self.players = [[Report latestReport].players array];
}

#pragma mark - Custom getters/setters

-(void)setPlayers:(NSArray *)players {
    _players = players;
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
    NSString *string = sender.stringValue;
    Game *game = [Game game];
    BOOL update = ![game.number isEqualToString:string];
    game.number = string;
    if(update) {
        SAVE(GET_MAIN_CONTEXT);
        [game resetAndLoad];
    }
}

- (IBAction)cookieUpdated:(NSTextField*)sender {
    NSString *string = sender.stringValue;
    Game *game = [Game game];
    BOOL update = ![game.cookie isEqualToString:string];
    game.cookie = string;
    if(update) {
        SAVE(GET_MAIN_CONTEXT);
        [game resetAndLoad];
    }
}

- (IBAction)syncServerUpdated:(NSTextField*)sender {
    NSString *string = sender.stringValue;
    Game *game = [Game game];
    BOOL update = ![game.syncServer isEqualToString:string];
    game.syncServer = string;
    if(update) {
        SAVE(GET_MAIN_CONTEXT);
        [game resetAndLoad];
    }
}

#pragma mark - Sharing

-(IBAction)buttonDown:(NSTableView*)sender {
    [sender setEnabled:NO];
    Player *player = [self.players objectAtIndex:self.currentPlayer];
    int status = player.shareStatus.intValue;
    if(status == OFFERED) {
        player.shareStatus = @(ACCEPTED);
        NSLog(@"%@: Offered -> Accepted", player.name);
        [player share];
    } else if(status == NONE) {
        player.shareStatus = @(OFFERING);
        NSLog(@"%@: None -> Offering", player.name);
        [player share];
    } else {
        player.shareStatus = @(NONE);
        NSLog(@"%@: * -> None", player.name);
        [player unshare];
    }
    SAVE(GET_MAIN_CONTEXT);

    [self reloadData];
    [sender setEnabled:YES];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.players.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    Player *player = self.players[rowIndex];
    if([aTableColumn.identifier isEqualToString:@"share"]) {
        int status = [player.shareStatus intValue];
        if(status >= OFFERING) {
            return @(YES);
        }
        return @(NO);
    } else if([aTableColumn.identifier isEqualToString:@"status"]) {
        switch([player.shareStatus intValue]) {
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
        return player.name;
    } else if([aTableColumn.identifier isEqualToString:@"lastUpdated"]) {
        NSDate *date = player.lastSync;
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