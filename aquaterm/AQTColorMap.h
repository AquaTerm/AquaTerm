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
    NSColor *minColor; // for continous colormaps
    NSColor *maxColor; // for continous colormaps
}
// Designated initializer
-(id)initWithColorDict:(NSDictionary *)indexColors
              rampFrom:(NSColor *)contColorMin
                    to:(NSColor *)contColorMax;
-(NSColor *)colorForFloat:(float)grey;
-(NSColor *)colorForIndex:(int)index;

// utility method
// -(NSColor *)interpolateColorFrom:(NSColor *)c0 to: (NSColor *)c1 by:(double)param;

@end