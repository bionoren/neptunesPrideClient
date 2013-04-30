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
#import "Fleet+Helpers.h"
#import "AppDelegate.h"

@interface MapView ()

@property (nonatomic, strong) NSScrollView *scrollView;

@end

@implementation MapView

-(void)awakeFromNib {
    [super awakeFromNib];

    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadData" object:nil];
}

-(void)reloadData {
    if(virtualFrame.size.width == 0) {
        virtualFrame = [self virtualFrame];
    }

    [self setNeedsDisplay:YES];
}

/** CDT ONLY */
-(CGRect)virtualFrame {
    float minx = MAXFLOAT;
    float miny = MAXFLOAT;
    float maxx = -MAXFLOAT;
    float maxy = -MAXFLOAT;
    for(Star *star in [Report latestReport].stars) {
        float x = [star.x floatValue];
        float y = [star.y floatValue];
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
#define FLEET_SIZE 20

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);

    if(virtualFrame.size.width == 0) {
        return;
    }

    Report *report = [Report latestReport];

    const float magnification = self.scrollView.magnification;
    float starSize = STAR_SIZE / magnification;
    float fleetSize = FLEET_SIZE / magnification;

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

    for(Star *star in report.stars) {
        float x = [star.x floatValue];
        float y = [star.y floatValue];
        float xoffsetPercent = (x - virtualFrame.origin.x) / virtualFrame.size.width;
        float yoffsetPercent = (y - virtualFrame.origin.y) / virtualFrame.size.height;
        float xoffset = bounds.width * xoffsetPercent + mapOffsetX;
        float yoffset = bounds.height * yoffsetPercent + mapOffsetY;

        NSBezierPath *starPath = [NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(xoffset - starSize / 2, bounds.height - (yoffset - starSize / 2), starSize, starSize))];
        if([star.visible boolValue]) {
            NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:star.player.color, (CGFloat)0, star.player.color, (CGFloat)0.35, [NSColor blackColor], (CGFloat)0.55, [NSColor whiteColor], (CGFloat)0.65, nil];
            [gradient drawInBezierPath:starPath relativeCenterPosition:NSZeroPoint];
        } else {
            [star.player.color setFill];
            [starPath stroke];
            [starPath fill];
        }

        if([star.visible boolValue] && magnification > 2) {
            [[NSString stringWithFormat:@"%@  %@  %@", star.economy, star.industry, star.science] drawAtPoint:NSMakePoint(xoffset - starSize / 2 - 6.5 / magnification, bounds.height - (yoffset - starSize / 2 - 20 / magnification)) withAttributes:@{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"Helvetica Light" size:12 / magnification]}];
            NSString *shipsString;
            if([star.industry floatValue] != 0) {
                shipsString = [NSString stringWithFormat:@"%d", star.allShips];
            } else {
                shipsString = [NSString stringWithFormat:@"%d", star.allShips];
            }
            [shipsString drawAtPoint:NSMakePoint(xoffset - starSize / 2 - 1 / magnification, bounds.height - (yoffset + starSize / 2)) withAttributes:@{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"Helvetica Light" size:12 / magnification]}];

            [[NSColor clearColor] setStroke];
        }
    }

    for(Fleet *fleet in report.fleets) {
        float x = [fleet.x floatValue];
        float y = [fleet.y floatValue];
        float xoffsetPercent = (x - virtualFrame.origin.x) / virtualFrame.size.width;
        float yoffsetPercent = (y - virtualFrame.origin.y) / virtualFrame.size.height;
        float xoffset = bounds.width * xoffsetPercent + mapOffsetX;
        float yoffset = bounds.height * yoffsetPercent + mapOffsetY;

        NSRect bound = NSMakeRect(xoffset - fleetSize / 2, bounds.height - (yoffset - fleetSize / 2), fleetSize, fleetSize);
        NSBezierPath *shipPath = [[NSBezierPath alloc] init];

#define CORNER_ANGLE (145 * 2 * M_PI / 360)
        if(fleet.waypoints.count) {
            Star *dest = fleet.waypoints[0];
            float destx = [dest.x floatValue];
            float desty = [dest.y floatValue];
            float destxOffsetPercent = (destx - virtualFrame.origin.x) / virtualFrame.size.width;
            float destyOffsetPercent = (desty - virtualFrame.origin.y) / virtualFrame.size.height;
            float destxOffset = bounds.width * destxOffsetPercent + mapOffsetX;
            float destyOffset = bounds.height * destyOffsetPercent + mapOffsetY;

            float theta = atan2f(destyOffset - yoffset, destxOffset - xoffset);
            float r = bound.size.width * 0.6;
            float ypartial = bounds.height - (yoffset - bound.size.height);
            [shipPath moveToPoint:NSMakePoint(xoffset + r * cosf(theta - CORNER_ANGLE),  ypartial - r * sinf(theta - CORNER_ANGLE))];
            [shipPath lineToPoint:NSMakePoint(xoffset + r * cosf(theta), ypartial - r * sinf(theta))];
            [shipPath lineToPoint:NSMakePoint(xoffset + r * cosf(theta + CORNER_ANGLE), ypartial - r * sinf(theta + CORNER_ANGLE))];
            [shipPath closePath];
        } else {
            [shipPath moveToPoint:bound.origin];
            [shipPath relativeLineToPoint:NSMakePoint(bound.size.width, 0)];
            [shipPath relativeLineToPoint:NSMakePoint(-bound.size.width / 2, bound.size.height)];
            [shipPath closePath];
        }

        if(!fleet.orbiting && magnification > 2) {
            NSString *shipsString = [NSString stringWithFormat:@"%@", fleet.ships];
            [shipsString drawAtPoint:NSMakePoint(xoffset - starSize / 2 - 1 / magnification, bounds.height - (yoffset + starSize / 2)) withAttributes:@{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"Helvetica Light" size:12 / magnification]}];
        }

        [fleet.player.color setFill];
        [shipPath stroke];
        [shipPath fill];
    }
}

@end
