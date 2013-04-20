//
//  MainViewController.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/17/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MainWindowController.h"
#import "MapView.h"
#import "AppDelegate.h"
#import "MyInfoWindowController.h"

@interface MainWindowController () <NSToolbarDelegate>

@property (nonatomic, strong) MyInfoWindowController *someWindow;

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window {
    if(self = [super initWithWindow:window]) {
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
        toolbar.allowsUserCustomization = YES;
        toolbar.autosavesConfiguration = YES;
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.delegate = self;

        self.window.toolbar = toolbar;
    }
    
    return self;
}

-(void)something:(id)sender {
    self.someWindow = [[MyInfoWindowController alloc] init];
    [self.someWindow showWindow:sender];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)item {
    return YES;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *ret = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    if(itemIdentifier == someIdentifier) {
        ret.label = @"Some ID";
        ret.paletteLabel = ret.label;
        ret.toolTip = ret.label;
        ret.image = [NSImage imageNamed:@"info.png"];
        ret.target = self;
        ret.action = @selector(something:);
        ret.enabled = YES;
    } else {
        NSLog(@"What is %@?", itemIdentifier);
    }
    return ret;
}

static const NSString *someIdentifier = @"someID";

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[someIdentifier, NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[someIdentifier, NSToolbarFlexibleSpaceItemIdentifier];
}

@end