//
//  Research.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Research : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * goal;
@property (nonatomic, retain) NSNumber * increment;
@property (nonatomic, retain) Player *player;

@end
