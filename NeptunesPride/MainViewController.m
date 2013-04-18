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

@interface MainViewController () <NSToolbarDelegate>

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, readonly) NSDictionary *stars;

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
    //curl "http://triton.ironhelmet.com/grequest/order" --data "type=order&order=full_universe_report&game_number=1429278"
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://triton.ironhelmet.com/grequest/order"]];
    [request setHTTPMethod:@"POST"];

    NSString *post =[NSString stringWithFormat:@"type=order&order=full_universe_report&game_number=%d", 1429278];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse *response;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }

    err = nil;
    self.data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err][@"report"];
    //NSLog(@"Data = %@", self.data);

    LOG_CGRECT(NSRectToCGRect(self.view.bounds));
    MapView *map = [[MapView alloc] initWithFrame:NSRectFromCGRect(self.view.bounds)];
    map.data = self.data;
    [((NSScrollView*)self.view) setDocumentView:map];
    [map setNeedsDisplay:YES];
}

-(NSDictionary*)stars {
    return self.data[@"stars"];
}

-(void)something:(id)sender {
    NSLog(@"Something!");
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

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return @[someIdentifier];
}

@end