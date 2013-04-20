//
//  Star+Helpers.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/19/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "Star+Helpers.h"
#import "AppDelegate.h"

@implementation Star (Helpers)

+(NSArray*)allStars {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Star"];
    NSError *err = nil;
    NSArray *ret = [GET_CONTEXT executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"ERROR: %@", err);
    }
    return ret;
}

@end