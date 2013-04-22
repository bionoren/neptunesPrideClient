//
//  Game.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Report;

@interface Game : NSManagedObject

@property (nonatomic, retain) NSString * cookie;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * syncServer;
@property (nonatomic, retain) NSNumber * tickRate;
@property (nonatomic, retain) NSNumber * starsForVictory;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * tradeCost;
@property (nonatomic, retain) NSNumber * fleetSpeed;
@property (nonatomic, retain) NSNumber * scienceCost;
@property (nonatomic, retain) NSNumber * industryCost;
@property (nonatomic, retain) NSNumber * economyCost;
@property (nonatomic, retain) NSNumber * productionRate;
@property (nonatomic, retain) NSOrderedSet *reports;
@end

@interface Game (CoreDataGeneratedAccessors)

- (void)insertObject:(Report *)value inReportsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReportsAtIndex:(NSUInteger)idx;
- (void)insertReports:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReportsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReportsAtIndex:(NSUInteger)idx withObject:(Report *)value;
- (void)replaceReportsAtIndexes:(NSIndexSet *)indexes withReports:(NSArray *)values;
- (void)addReportsObject:(Report *)value;
- (void)removeReportsObject:(Report *)value;
- (void)addReports:(NSOrderedSet *)values;
- (void)removeReports:(NSOrderedSet *)values;
@end
