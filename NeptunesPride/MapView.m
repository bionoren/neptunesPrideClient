//
//  MapView.m
//  NeptunesPride
//
//  Created by Bion Oren on 4/18/13.
//  Copyright (c) 2013 Bion Oren. All rights reserved.
//

#import "MapView.h"
#import "Star+Helpers.h"
#import "Player+Helpers.h"
#import "NSManagedObject+Helpers.h"

@implementation MapView

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
    }
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];

    [NSManagedObject loadData];
}

-(CGRect)virtualFrame {
    float minx = MAXFLOAT;
    float miny = MAXFLOAT;
    float maxx = -MAXFLOAT;
    float maxy = -MAXFLOAT;
    for(Star *star in [Star allStars]) {
        float x = star.x.floatValue;
        float y = star.y.floatValue;
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

static CGRect virtualFrame = {0};

- (void)drawRect:(NSRect)dirtyRect {
    if(virtualFrame.size.width == 0) {
        virtualFrame = [self virtualFrame];
    }
    //LOG_CGRECT(frame);

    for(Star *star in [Star allStars]) {
        [star.player.color set];
        float x = star.x.floatValue;
        float y = star.y.floatValue;
        float xoffsetPercent = (x - virtualFrame.origin.x) / virtualFrame.size.width;
        float yoffsetPercent = (y - virtualFrame.origin.y) / virtualFrame.size.height;
        float xoffset = self.bounds.size.width * xoffsetPercent;
        float yoffset = self.bounds.size.height * yoffsetPercent;
        //NSLog(@"xoffset = %f", xoffset);
        //NSLog(@"yoffset = %f", yoffset);

        NSBezierPath *starPath = [[NSBezierPath alloc] init];
        [starPath appendBezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(xoffset - 5, self.bounds.size.height - (yoffset - 5), 10, 10))];
        [starPath stroke];
        [starPath fill];
    }
}

@end
