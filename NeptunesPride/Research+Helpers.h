//
//  Research+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Research.h"

extern const NSString *BANKING;
extern const NSString *MANUFACTURING;
extern const NSString *HYPERSPACE;
extern const NSString *GENERAL;
extern const NSString *SCANNING;
extern const NSString *TERRAFORMING;
extern const NSString *WEAPONS;

@interface Research (Helpers)

+(Research*)research:(const NSString*)research forPlayer:(Player*)player;
+(int)levelForResearch:(const NSString*)research forPlayer:(Player*)player;
+(float)valueForResearch:(const NSString*)research forPlayer:(Player*)player;

@end