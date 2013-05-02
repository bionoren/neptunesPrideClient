//
//  Fleet+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/22/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Fleet.h"
#import "Report.h"

@interface Fleet (Helpers)

+(NSArray*)allFleetsInReport:(Report*)report;
+(NSArray*)dataForReport:(Report*)report;
+(Fleet*)fleetFromUID:(int)uid inReport:(Report*)report;

-(NSPoint)point;

@end