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
#import "Game+Helpers.h"
#import "PreferencesWindowController.h"

@interface MainWindowController ()

@property (nonatomic, strong) MyInfoWindowController *someWindow;
@property (nonatomic, strong) PreferencesWindowController *preferencesWindow;

@end

@implementation MainWindowController

-(void)awakeFromNib {
    [super awakeFromNib];

    dispatch_async(dispatch_get_main_queue(), ^{
        [Game loadData];
    });
}

-(IBAction)showPlayerInfo:(id)sender {
    self.someWindow = [[MyInfoWindowController alloc] init];
    [self.someWindow showWindow:sender];
}

-(IBAction)showPreferences:(id)sender {
    self.preferencesWindow = [[PreferencesWindowController alloc] init];
    [self.preferencesWindow showWindow:sender];
}

@end