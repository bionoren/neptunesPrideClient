//
//  Report.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/30/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fleet, Game, Player, Star;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * collectionTime;
@property (nonatomic, retain) NSDate * gameTime;
@property (nonatomic, retain) NSNumber * originatorUID;
@property (nonatomic, retain) NSNumber * tick;
@property (nonatomic, retain) NSNumber * tick_fragment;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSOrderedSet *players;
@property (nonatomic, retain) NSSet *stars;
@property (nonatomic, retain) NSSet *fleets;
@end

@interface Report (CoreDataGeneratedAccessors)

- (void)insertObject:(Player *)value inPlayersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlayersAtIndex:(NSUInteger)idx;
- (void)insertPlayers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlayersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlayersAtIndex:(NSUInteger)idx withObject:(Player *)value;
- (void)replacePlayersAtIndexes:(NSIndexSet *)indexes withPlayers:(NSArray *)values;
- (void)addPlayersObject:(Player *)value;
- (void)removePlayersObject:(Player *)value;
- (void)addPlayers:(NSOrderedSet *)values;
- (void)removePlayers:(NSOrderedSet *)values;
- (void)addStarsObject:(Star *)value;
- (void)removeStarsObject:(Star *)value;
- (void)addStars:(NSSet *)values;
- (void)removeStars:(NSSet *)values;

- (void)addFleetsObject:(Fleet *)value;
- (void)removeFleetsObject:(Fleet *)value;
- (void)addFleets:(NSSet *)values;
- (void)removeFleets:(NSSet *)values;

@end
