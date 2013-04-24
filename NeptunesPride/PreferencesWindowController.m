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

@interface PreferencesWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSScrollView *sharingView;
@property (weak) IBOutlet NSView *settingsView;
@property (weak) IBOutlet NSTextField *gameNumberField;
@property (weak) IBOutlet NSTextField *cookieField;
@property (weak) IBOutlet NSTextField *shareServerField;
@property (weak) IBOutlet NSTextField *lastSyncLabel;

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
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

-(void)reloadData {
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

- (IBAction)reloadData:(NSButton *)sender {
    [NSManagedObject resetAndLoad];
}

- (IBAction)gameUpdated:(NSTextField*)sender {
    [Game game].number = sender.stringValue;
    SAVE_CONTEXT;
    [self reloadData:nil];
}

- (IBAction)cookieUpdated:(NSTextField*)sender {
    [Game game].cookie = sender.stringValue;
    SAVE_CONTEXT;
    [self reloadData:nil];
}

- (IBAction)syncServerUpdated:(NSTextField*)sender {
    [Game game].syncServer = sender.stringValue;
    SAVE_CONTEXT;
    [self reloadData:nil];
}

#pragma mark - Sharing

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return nil;
}

#pragma mark NSTableViewDataDelegate

@end