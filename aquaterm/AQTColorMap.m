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
        @"8",
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
{
    // need to call [self interpolateColorFrom:to:by: ] (Just replace it! PP)
    // but I am not quite sure how -- is c0 max or min? 
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
{
    // I am not completely sure about the ramifications of the modulo 9
    // but that was how the old code worked. I assume it has something to
    // do with gnuplot internals -- bobs
    return [indexedColormap objectForKey:[NSString stringWithFormat:@"%d", index % 9]];
}
/*
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
*/
@end
