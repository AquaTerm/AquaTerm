//
//  AQTPath.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTGraphic.h"

@interface AQTPath : AQTGraphic
{
    NSBezierPath *path;	/*" A collection of bezier paths sharing the same (style)properties "*/
    BOOL isFilled;
    float mappedColor;	/*" The parametrized fill color [0..1] "*/
}
-(id)initWithPath:(NSBezierPath *)aPath filled:(BOOL)filled color:(float)gray colorIndex:(int)cIndex indexedColor:(BOOL)icFlag;
-(id)initWithPolyline:(NSBezierPath *)aPath color:(float)gray;
-(id)initWithPolyline:(NSBezierPath *)aPath colorIndex:(int)cIndex;
-(id)initWithPolygon:(NSBezierPath *)aPath color:(float)gray;
-(id)initWithPolygon:(NSBezierPath *)aPath colorIndex:(int)cIndex;
-(void)renderInRect:(NSRect)boundsRect;
@end
