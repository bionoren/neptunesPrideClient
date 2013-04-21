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
#import "Report+Helpers.h"

@interface MapView ()

@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;

@end

@implementation MapView

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
    }
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];

    Report *report = [NSManagedObject loadData];
    NSTimeInterval timeToNextPossibleUpdate = [report timeToPossibleUpdate];
    [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate target:[NSManagedObject class] selector:@selector(loadData) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:timeToNextPossibleUpdate + 15 * 60 target:[NSManagedObject class] selector:@selector(loadData) userInfo:nil repeats:YES];
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

    float starSize = STAR_SIZE / self.scrollView.magnification;

    NSSize bounds = self.bounds.size;
    float scale = virtualFrame.size.width / virtualFrame.size.height;
    CGFloat mapOffsetX = 0;
    CGFloat mapOffsetY = 0;
    float computedWidth = bounds.height * scale;
    if(computedWidth > bounds.width) {
        bounds = NSMakeSize(bounds.width, bounds.width / scale);
        mapOffsetY = -(self.bounds.size.height - bounds.height) / 2;
    } else {
        bounds = NSMakeSize(bounds.height * scale, bounds.height);
        mapOffsetX = (self.bounds.size.width - bounds.width) / 2;
    }

    for(Star *star in [Star allStars]) {
        float x = star.x.floatValue;
        float y = star.y.floatValue;
        float xoffsetPercent = (x - virtualFrame.origin.x) / virtualFrame.size.width;
        float yoffsetPercent = (y - virtualFrame.origin.y) / virtualFrame.size.height;
        float xoffset = bounds.width * xoffsetPercent + mapOffsetX;
        float yoffset = bounds.height * yoffsetPercent + mapOffsetY;

        NSBezierPath *starPath = [[NSBezierPath alloc] init];
        [starPath appendBezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(xoffset - starSize / 2, bounds.height - (yoffset - starSize / 2), starSize, starSize))];
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
