//
//  Report+Helpers.h
//  NeptunesPride
//
//  Created by Bion Oren on 4/20/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Report.h"

@interface Report (Helpers)

+(Report*)latestReport;
+(Report*)reportForTick:(NSNumber*)tick;

-(void)setLatest;
-(NSTimeInterval)timeToPossibleUpdate;
-(void)push;
-(void)pull;

@end