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
#import "GameTimeToolbarItem.h"
#import "Report+Helpers.h"

@interface MainWindowController ()

@property (nonatomic, weak) IBOutlet GameTimeToolbarItem *gameTimeToolbarItem;
@property (weak) IBOutlet NSSlider *gameTimeSlider;
@property (weak) IBOutlet NSStepper *gameTimeStepper;

@property (nonatomic, strong) MyInfoWindowController *someWindow;
@property (nonatomic, strong) PreferencesWindowController *preferencesWindow;

@end

@implementation MainWindowController

-(void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadData" object:nil];
    [Game loadData];
}

-(void)reloadData {
    Report *report = [Report latestReport];
    self.gameTimeToolbarItem.report = [Report latestReport];
    int tick = report.tick.intValue;
    if(tick > self.gameTimeSlider.maxValue) {
        self.gameTimeSlider.maxValue = tick;
        self.gameTimeStepper.maxValue = tick;
    }
    self.gameTimeSlider.intValue = tick;
    self.gameTimeStepper.intValue = tick;
}

-(IBAction)showPlayerInfo:(id)sender {
    self.someWindow = [[MyInfoWindowController alloc] init];
    [self.someWindow showWindow:sender];
}

-(IBAction)showPreferences:(id)sender {
    self.preferencesWindow = [[PreferencesWindowController alloc] init];
    [self.preferencesWindow showWindow:sender];
}

#pragma mark - View Tick

- (IBAction)scrollToTick:(NSSlider *)sender {
    [self showTick:sender.intValue];
    [self.gameTimeStepper takeIntValueFrom:sender];
}

- (IBAction)stepToTick:(NSStepper *)sender {
    [self showTick:sender.intValue];
    [self.gameTimeSlider takeIntValueFrom:sender];
}

-(void)showTick:(int)tick {
    Report *report = [Report reportForTick:@(tick)];
    if(report) {
        [report setLatest];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
    }
}

@end