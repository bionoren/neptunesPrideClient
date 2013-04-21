//
//  Star+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Star.h"
#import "Report.h"

@interface Star (Helpers)

+(NSArray*)allStarsInReport:(Report*)report;

-(NSNumber*)numFleets;

@end