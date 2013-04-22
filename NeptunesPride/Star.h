//
//  Star.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Star : NSManagedObject

@property (nonatomic, retain) NSNumber * buildRate;
@property (nonatomic, retain) NSNumber * economy;
@property (nonatomic, retain) NSNumber * garrison;
@property (nonatomic, retain) NSNumber * industry;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * naturalResources;
@property (nonatomic, retain) NSNumber * resources;
@property (nonatomic, retain) NSNumber * science;
@property (nonatomic, retain) NSNumber * ships;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) Player *player;

@end
