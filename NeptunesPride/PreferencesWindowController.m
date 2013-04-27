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
    [NSManagedObject loadShareData];
    [self.sharingView setHidden:YES];

    [self reloadPlayerData];
    [GET_CONTEXT performBlock:^{
        Game *game = [Game game];
        NSString *number = game.number;
        NSString *cookie = game.cookie;
        NSString *syncServer = game.syncServer;

        dispatch_async(dispatch_get_main_queue(), ^{
            if(number.length) {
                self.gameNumberField.stringValue = number;
            }
            if(cookie.length) {
                self.cookieField.stringValue = cookie;
            }
            if(syncServer.length) {
                self.shareServerField.stringValue = syncServer;
            }

            [self reloadData];
        });
    }];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

-(IBAction)reloadData:(id)sender {
    [NSManagedObject resetAndLoad];
    [self reloadPlayerData];
}

-(void)reloadPlayerData {
    [GET_CONTEXT performBlock:^{
        NSMutableArray *players = [[NSMutableArray alloc] init];
        for(Player *player in [Report latestReport].players) {
            NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
            p[@"playerObj"] = player;
            p[@"shareStatus"] = player.shareStatus;
            p[@"name"] = player.name;
            NSDate *lastSync = player.lastSync;
            if(lastSync) {
                p[@"lastSync"] = lastSync;
            }
            [players addObject:p];
        }
        self.players = players;
    }];
}

-(void)reloadData {
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
    [GET_CONTEXT performBlock:^{
        BOOL update = ![[Game game].number isEqualToString:string];
        [Game game].number = string;
        if(update) {
            SAVE_CONTEXT;
            [NSManagedObject resetAndLoad];
        }
    }];
}

- (IBAction)cookieUpdated:(NSTextField*)sender {
    NSString *string = sender.stringValue;
    [GET_CONTEXT performBlock:^{
        BOOL update = ![[Game game].cookie isEqualToString:string];
        [Game game].cookie = string;
        if(update) {
            SAVE_CONTEXT;
            [NSManagedObject resetAndLoad];
        }
    }];
}

- (IBAction)syncServerUpdated:(NSTextField*)sender {
    NSString *string = sender.stringValue;
    [GET_CONTEXT performBlock:^{
        BOOL update = ![[Game game].syncServer isEqualToString:string];
        [Game game].syncServer = string;
        if(update) {
            SAVE_CONTEXT;
            [NSManagedObject resetAndLoad];
        }
    }];
}

#pragma mark - Sharing

-(IBAction)buttonDown:(NSTableView*)sender {
    [sender setEnabled:NO];
    [GET_CONTEXT performBlock:^{
        NSMutableDictionary *playerDict = [self.players objectAtIndex:self.currentPlayer];
        Player *player = playerDict[@"playerObj"];
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
        playerDict[@"shareStatus"] = player.shareStatus;
        SAVE_CONTEXT;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            [sender setEnabled:YES];
        });
    }];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.players.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if([aTableColumn.identifier isEqualToString:@"share"]) {
        int status = [self.players[rowIndex][@"shareStatus"] intValue];
        if(status >= OFFERING) {
            return @(YES);
        }
        return @(NO);
    } else if([aTableColumn.identifier isEqualToString:@"status"]) {
        switch([self.players[rowIndex][@"shareStatus"] intValue]) {
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
        return self.players[rowIndex][@"name"];
    } else if([aTableColumn.identifier isEqualToString:@"lastUpdated"]) {
        NSDate *date = self.players[rowIndex][@"lastSync"];
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