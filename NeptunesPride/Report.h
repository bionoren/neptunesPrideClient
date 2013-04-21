//
//  Report.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * gameTime;
@property (nonatomic, retain) NSNumber * originatorUID;
@property (nonatomic, retain) NSNumber * tick;
@property (nonatomic, retain) NSNumber * tick_fragment;
@property (nonatomic, retain) NSDate * collectionTime;
@property (nonatomic, retain) NSOrderedSet *players;
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
@end
