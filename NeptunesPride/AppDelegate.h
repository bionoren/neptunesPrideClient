//
//  AppDelegate.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/17/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GET_CONTEXT [(AppDelegate*)[NSApplication sharedApplication].delegate managedObjectContext]
#define GET_MAIN_CONTEXT [(AppDelegate*)[NSApplication sharedApplication].delegate mainManagedObjectContext]
#define SAVE_CONTEXT [(AppDelegate*)[NSApplication sharedApplication].delegate saveAction:nil]
#define FETCH_REQUEST(fetchRequest, context) [(AppDelegate*)[NSApplication sharedApplication].delegate executeFetchRequest:fetchRequest inContext:context]
#define FETCH(fetchRequest) FETCH_REQUEST(fetchRequest, GET_CONTEXT)
#define FETCH_MAIN(fetchRequest) FETCH_REQUEST(fetchRequest, GET_MAIN_CONTEXT)

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

- (IBAction)saveAction:(id)sender;
-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context;

@end
