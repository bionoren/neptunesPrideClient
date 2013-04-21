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
#import "Report+Helpers.h"
#import "NSManagedObject+Helpers.h"

@interface MainWindowController ()

@property (nonatomic, strong) MyInfoWindowController *someWindow;

@end

@implementation MainWindowController

-(void)awakeFromNib {
    [super awakeFromNib];

    dispatch_async(dispatch_get_main_queue(), ^{
        Report *report = [NSManagedObject loadData];
        NSTimeInterval timeToNextPossibleUpdate = [report timeToPossibleUpdate];
        [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate target:[NSManagedObject class] selector:@selector(loadData) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate + 15 * 60 target:[NSManagedObject class] selector:@selector(loadData) userInfo:nil repeats:YES];
    });
}

-(IBAction)showPlayerInfo:(id)sender {
    self.someWindow = [[MyInfoWindowController alloc] init];
    [self.someWindow showWindow:sender];
}

@end