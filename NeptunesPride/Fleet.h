//
//  Fleet.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/23/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, Star;

@interface Fleet : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ships;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSOrderedSet *waypoints;
@property (nonatomic, retain) Star *orbiting;
@end

@interface Fleet (CoreDataGeneratedAccessors)

- (void)insertObject:(Star *)value inWaypointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWaypointsAtIndex:(NSUInteger)idx;
- (void)insertWaypoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWaypointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWaypointsAtIndex:(NSUInteger)idx withObject:(Star *)value;
- (void)replaceWaypointsAtIndexes:(NSIndexSet *)indexes withWaypoints:(NSArray *)values;
- (void)addWaypointsObject:(Star *)value;
- (void)removeWaypointsObject:(Star *)value;
- (void)addWaypoints:(NSOrderedSet *)values;
- (void)removeWaypoints:(NSOrderedSet *)values;
@end
