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

#define STAR_SIZE 20

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);

    if(virtualFrame.size.width == 0) {
        virtualFrame = [self virtualFrame];
    }
    //LOG_CGRECT(frame);

    for(Star *star in [Star allStars]) {
        //[star.player.color set];
        float x = star.x.floatValue;
        float y = star.y.floatValue;
        float xoffsetPercent = (x - virtualFrame.origin.x) / virtualFrame.size.width;
        float yoffsetPercent = (y - virtualFrame.origin.y) / virtualFrame.size.height;
        float xoffset = self.bounds.size.width * xoffsetPercent;
        float yoffset = self.bounds.size.height * yoffsetPercent;
        //NSLog(@"xoffset = %f", xoffset);
        //NSLog(@"yoffset = %f", yoffset);

        NSBezierPath *starPath = [[NSBezierPath alloc] init];
        [starPath appendBezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(xoffset - STAR_SIZE / 2, self.bounds.size.height - (yoffset - STAR_SIZE / 2), STAR_SIZE, STAR_SIZE))];
        if(star.visible.boolValue) {
            NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:star.player.color, (CGFloat)0, star.player.color, (CGFloat)0.35, [NSColor blackColor], (CGFloat)0.55, [NSColor whiteColor], (CGFloat)0.65, nil];
            [gradient drawInBezierPath:starPath relativeCenterPosition:NSZeroPoint];
        } else {
            [star.player.color setFill];
            [starPath stroke];
            [starPath fill];
        }
    }
}

@end
