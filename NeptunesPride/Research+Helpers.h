//
//  Research+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/21/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Research.h"

static const NSString *BANKING = @"banking";
static const NSString *MANUFACTURING = @"manufacturing";
static const NSString *HYPERSPACE = @"propulsion";
static const NSString *GENERAL = @"research";
static const NSString *SCANNING = @"scanning";
static const NSString *TERRAFORMING = @"terraforming";
static const NSString *WEAPONS = @"weapons";

@interface Research (Helpers)

+(float)valueForResearch:(const NSString*)research forPlayer:(Player*)player;

@end