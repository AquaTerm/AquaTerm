//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import "AQTColorMap.h"

@implementation AQTColorMap
-(id)initWithColorDict:(NSDictionary *)indexColors
              rampFrom:(NSColor *)contColorMin
                    to:(NSColor *)contColorMax
{
    if (self = [super init]) {
        indexedColormap = [indexColors retain];
        minColor = [contColorMin retain];
        maxColor = [contColorMax retain];
    }
    return self;
}

-(void)dealloc {
    [indexedColormap release];
    [minColor release];
    [maxColor release];
    [super dealloc];
}

-(NSColor *)colorForFloat:(float)grey
{
    // need to call [self interpolateColorFrom:to:by: ]
    // but I am not quite sure how -- is c0 max or min?
}

-(NSColor *)colorForIndex:(int)index
{
    // I am not completely sure about the ramifications of the modulo 9
    // but that was how the old code worked. I assume it has something to
    // do with gnuplot internals -- bobs
    return [indexedColormap objectForKey:[NSString stringWithFormat:@"%d", index % 9]];
}

-(NSColor *)interpolateColorFrom:(NSColor *)c0 to: (NSColor *)c1 by:(double)param
{
    float   r  = [c0 redComponent],
            g  = [c0 greenComponent],
            b  = [c0 blueComponent];
    float   zr = -(r - [c1 redComponent]),
            zg = -(g - [c1 greenComponent]),
            zb = -(b - [c1 blueComponent]);
    
    return [NSColor colorWithCalibratedRed:r+zr*param 
                                     green:g+zg*param 
                                      blue:b+zb*param 
                                     alpha:1.0];
}

@end
