//
//  AQTPath.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTGraphic.h"

@interface AQTPath : AQTGraphic /*" NSObject "*/
{
    NSBezierPath *path;	/*" A collection of bezier paths sharing the same (style)properties "*/
    BOOL hasIndexedColor; /*" TRUE => fill and stroke in _fillColor; FALSE => stroke in _strokeColor "*/
    BOOL isFilled;
}
-(id)initWithPath:(NSBezierPath *)aPath filled:(BOOL)filled color:(NSColor *)color colorIndex:(int)cIndex indexedColor:(BOOL)icFlag;
-(id)initWithPolyline:(NSBezierPath *)aPath colorIndex:(int)cIndex;
-(id)initWithPolygon:(NSBezierPath *)aPath colorIndex:(int)cIndex;
-(id)initWithPolyline:(NSBezierPath *)aPath color:(NSColor *)color;
-(id)initWithPolygon:(NSBezierPath *)aPath color:(NSColor *)color;
-(void)renderInRect:(NSRect)boundsRect;
@end
