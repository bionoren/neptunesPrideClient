//
//  MapView.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/18/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MapView.h"

@implementation MapView

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
    }
    
    return self;
}

-(CGRect)virtualFrame {
    float minx = MAXFLOAT;
    float miny = MAXFLOAT;
    float maxx = -MAXFLOAT;
    float maxy = -MAXFLOAT;
    for(NSDictionary *star in [self.stars objectEnumerator]) {
        float x = [star[@"x"] floatValue];
        float y = [star[@"y"] floatValue];
        if(x < minx) {
            minx = x;
        }
        if(x > maxx) {
            maxx = x;
        }
        if(y < miny) {
            miny = y;
        }
        if(y > maxy) {
            maxy = y;
        }
    }
    float width = maxx - minx;
    float height = maxy - miny;
    return CGRectMake(minx - 0.1*width, miny - 0.1*height, width*1.2, height*1.2);
}

- (void)drawRect:(NSRect)dirtyRect {
    if(self.data) {
        CGRect frame = [self virtualFrame];
        //LOG_CGRECT(frame);

        [[NSColor greenColor] set];
        for(NSDictionary *star in [self.stars objectEnumerator]) {
            float x = [star[@"x"] floatValue];
            float y = [star[@"y"] floatValue];
            float xoffsetPercent = (x - frame.origin.x) / frame.size.width;
            float yoffsetPercent = (y - frame.origin.y) / frame.size.height;
            float xoffset = self.bounds.size.width * xoffsetPercent;
            float yoffset = self.bounds.size.height * yoffsetPercent;
            //NSLog(@"xoffset = %f", xoffset);
            //NSLog(@"yoffset = %f", yoffset);

            NSBezierPath *starPath = [[NSBezierPath alloc] init];
            [starPath appendBezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(xoffset - 5, self.bounds.size.height - (yoffset - 5), 10, 10))];
            [starPath stroke];
            [starPath fill];
        }
    } else {
        NSLog(@"No data");
    }
}

-(NSDictionary*)stars {
    return self.data[@"stars"];
}

@end
