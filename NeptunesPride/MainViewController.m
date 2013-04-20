//
//  MainViewController.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/17/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MainViewController.h"
#import "MapView.h"
#import "AppDelegate.h"
#import "MyInfoWindowController.h"
#import "MainViewController+loadData.h"

@interface MainViewController () <NSToolbarDelegate>

@property (nonatomic, strong) MyInfoWindowController *someWindow;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self reloadData];

        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
        toolbar.allowsUserCustomization = YES;
        toolbar.autosavesConfiguration = YES;
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.delegate = self;

        ((AppDelegate*)[NSApplication sharedApplication].delegate).window.toolbar = toolbar;
    }
    
    return self;
}

-(IBAction)reloadData {
    [self loadData];

    LOG_CGRECT(NSRectToCGRect(self.view.bounds));
    MapView *map = [[MapView alloc] initWithFrame:NSRectFromCGRect(self.view.bounds)];
    [((NSScrollView*)self.view) setDocumentView:map];
    [map setNeedsDisplay:YES];
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