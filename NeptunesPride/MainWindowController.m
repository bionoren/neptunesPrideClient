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

@interface MainWindowController ()

@property (nonatomic, strong) MyInfoWindowController *someWindow;

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window {
    if(self = [super initWithWindow:window]) {
    }
    
    return self;
}

-(IBAction)showPlayerInfo:(id)sender {
    self.someWindow = [[MyInfoWindowController alloc] init];
    [self.someWindow showWindow:sender];
}

@end