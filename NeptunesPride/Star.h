//
//  Star.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/30/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fleet, Player, Report;

@interface Star : NSManagedObject

@property (nonatomic, retain) NSNumber * economy;
@property (nonatomic, retain) NSNumber * garrison;
@property (nonatomic, retain) NSNumber * industry;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * naturalResources;
@property (nonatomic, retain) NSNumber * science;
@property (nonatomic, retain) NSNumber * ships;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSSet *fleets;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Report *report;
@end

@interface Star (CoreDataGeneratedAccessors)

- (void)addFleetsObject:(Fleet *)value;
- (void)removeFleetsObject:(Fleet *)value;
- (void)addFleets:(NSSet *)values;
- (void)removeFleets:(NSSet *)values;

@end
