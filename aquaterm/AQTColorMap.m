//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import "AQTColorMap.h"

@implementation AQTColorMap
    /**"
    *** Mappings for colors both indexed and gradient for a particular AQTModel. 
    "**/
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

-(id)init
{
  // create a color dictionary
    NSDictionary *aColorDict =
    [NSDictionary dictionaryWithObjects:
      [NSArray arrayWithObjects:
        [NSColor whiteColor], // -4
        [NSColor yellowColor], // -3
        [NSColor blackColor], // -2
        [NSColor lightGrayColor], // -1
        [NSColor redColor], // 0
        [NSColor greenColor], // 1
        [NSColor blueColor], // 2
        [NSColor cyanColor], // 3
        [NSColor magentaColor], // 4
        [NSColor orangeColor], // 5
        [NSColor purpleColor], // 6
        [NSColor brownColor], // 7
        [NSColor grayColor], // 8
        nil]
    forKeys:
      [NSArray arrayWithObjects:
        @"-4", // ? backgroundColor
        @"-3", // ?
        @"-2", // ?
        @"-1", // ?
        @"0", // lineColor1
        @"1", // lineColor2
        @"2", // lineColor3
        @"3", // lineColor4
        @"4", // lineColor5
        @"5", // lineColor6
        @"6", // lineColor7
        @"7", // lineColor8
        @"8", // lineColor9
        nil]
      ];

  return [self initWithColorDict:aColorDict rampFrom:[NSColor blueColor] to:[NSColor yellowColor]];
}

-(void)dealloc {
    [indexedColormap release];
    [minColor release];
    [maxColor release];
    [super dealloc];
}

-(NSColor *)colorForFloat:(float)param
/*" returns a color corresponding to a point on a gradient "*/
{
  float	r  = [minColor redComponent],
        g  = [minColor greenComponent],
        b  = [minColor blueComponent];
  float	zr = [maxColor redComponent] - r,
        zg = [maxColor greenComponent] - g,
        zb = [maxColor blueComponent] - b;

  return [NSColor colorWithCalibratedRed:r+zr*param
                                   green:g+zg*param
                                    blue:b+zb*param
                                   alpha:1.0];
}

-(NSColor *)colorForIndex:(int)index
    /**"
    *** Gnuplot uses is a color index to map linestyles to a set of fixed
    *** colors. The index is taken modulo max_number_of_colors.
    *** Negative numbers have special meanings (-2 = axes, -1 = grid).
    "**/
{
    // magic number? perhaps thi should be made a #define
    return [indexedColormap objectForKey:[NSString stringWithFormat:@"%d", index % 9]]; 
}

@end
