//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AQTColorMap : NSObject	
{
    NSDictionary *indexedColormap;
    
    /*
    // could we rename these maxColor and minColor?
    // seems more descriptive -- bobs
    NSColor *color1; // for continous colormaps
    NSColor *color2; // for continous colormaps
    */
    NSColor *minColor; // for continous colormaps
    NSColor *maxColor; // for continous colormaps
}
-(id)initWithColorDict:(NSDictionary *)indexColors
              rampFrom:(NSColor *)contColorMin
                    to:(NSColor *)contColorMax;
-(NSColor *)colorForFloat:(float)grey;
-(NSColor *)colorForIndex:(int)index;

// utility method
-(NSColor *)interpolateColorFrom:(NSColor *)c0 to: (NSColor *)c1 by:(double)param;

@end