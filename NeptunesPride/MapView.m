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
#import "Report+Helpers.h"

@interface MapView ()

@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) id<NSFastEnumeration> stars;

@end

@implementation MapView

-(void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadData" object:nil];
}

-(void)reloadData {
    self.stars = [Star allStarsInReport:[Report latestReport]];
    if(!self.stars) {
        return;
    }
    if(virtualFrame.size.width == 0) {
        virtualFrame = [self virtualFrame];
    }

    [self setNeedsDisplay:YES];
}

-(CGRect)virtualFrame {
    float minx = MAXFLOAT;
    float miny = MAXFLOAT;
    float maxx = -MAXFLOAT;
    float maxy = -MAXFLOAT;
    for(Star *star in self.stars) {
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

-(void)setFrameSize:(NSSize)newSize {
    self.scrollView = [self enclosingScrollView];
    [super setFrameSize:self.scrollView.frame.size];
}

static CGRect virtualFrame = {0};

#define STAR_SIZE 20

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);

    if(virtualFrame.size.width == 0) {
        return;
    }

    const float magnification = self.scrollView.magnification;
    float starSize = STAR_SIZE / magnification;

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

    for(Star *star in self.stars) {
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

        if(star.visible.boolValue && magnification > 2) {
            [[NSString stringWithFormat:@"%@  %@  %@", star.economy, star.industry, star.science] drawAtPoint:NSMakePoint(xoffset - starSize / 2 - 6.5 / magnification, bounds.height - (yoffset - starSize / 2 - 20 / magnification)) withAttributes:@{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"Helvetica Light" size:12 / magnification]}];
            NSString *shipsString;
            if(star.industry.floatValue != 0) {
                shipsString = [NSString stringWithFormat:@"%@", star.ships];
            } else {
                shipsString = [NSString stringWithFormat:@"%@", star.ships];
            }
            [shipsString drawAtPoint:NSMakePoint(xoffset - starSize / 2 - 1 / magnification, bounds.height - (yoffset + starSize / 2)) withAttributes:@{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"Helvetica Light" size:12 / magnification]}];

            [[NSColor clearColor] setStroke];
        }
    }
}

@end
