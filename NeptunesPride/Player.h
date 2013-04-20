//
//  Player.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fleet, Star;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * economy;
@property (nonatomic, retain) NSNumber * industry;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numFleets;
@property (nonatomic, retain) NSNumber * science;
@property (nonatomic, retain) NSNumber * strength;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSOrderedSet *fleets;
@property (nonatomic, retain) NSOrderedSet *stars;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)insertObject:(Fleet *)value inFleetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFleetsAtIndex:(NSUInteger)idx;
- (void)insertFleets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFleetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFleetsAtIndex:(NSUInteger)idx withObject:(Fleet *)value;
- (void)replaceFleetsAtIndexes:(NSIndexSet *)indexes withFleets:(NSArray *)values;
- (void)addFleetsObject:(Fleet *)value;
- (void)removeFleetsObject:(Fleet *)value;
- (void)addFleets:(NSOrderedSet *)values;
- (void)removeFleets:(NSOrderedSet *)values;
- (void)insertObject:(Star *)value inStarsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStarsAtIndex:(NSUInteger)idx;
- (void)insertStars:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStarsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStarsAtIndex:(NSUInteger)idx withObject:(Star *)value;
- (void)replaceStarsAtIndexes:(NSIndexSet *)indexes withStars:(NSArray *)values;
- (void)addStarsObject:(Star *)value;
- (void)removeStarsObject:(Star *)value;
- (void)addStars:(NSOrderedSet *)values;
- (void)removeStars:(NSOrderedSet *)values;
@end
