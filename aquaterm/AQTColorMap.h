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
    NSColor *minColor; /*" for continous colormaps "*/
    NSColor *maxColor; /*" for continous colormaps "*/
}
/*" Designated initializer "*/
-(id)initWithColorDict:(NSDictionary *)indexColors
              rampFrom:(NSColor *)contColorMin
                    to:(NSColor *)contColorMax;

/*" accessor methods "*/
-(NSColor *)colorForFloat:(float)grey;
-(NSColor *)colorForIndex:(int)index;

@end