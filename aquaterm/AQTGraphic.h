//
//  AQTGraphic.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AQTColorMap;

@interface AQTGraphic : NSObject
{
    NSColor *color;
  /* hasIndexedColor should be part of the subclasses that have an option! */
//     BOOL hasIndexedColor; /*" TRUE => fill and stroke in _fillColor; FALSE => stroke in _strokeColor "*/
    int colorIndex;	  /*" Could mean color or linestyle (dash) depending on graphic object "*/
}

/*" accessor methods "*/
-(NSRect)bounds;
-(void)addObject:(AQTGraphic *)graphic;
-(void)removeObject:(AQTGraphic *)graphic;
-(void)removeObjectsInRect:(NSRect)targetRect;

/*" drawing "*/
-(void)renderInRect:(NSRect)boundsRect;

// - will be removed next time I see it <BS>
/* this has to go, not compliant with new color handling
-(void)setColorFromIndex:(int)colorIndex;
*/

/*" color handling "*/
-(NSColor *)color;
-(void)setColor:(NSColor *)newColor;
-(void)updateColors:(AQTColorMap *)colorMap; // the new color handling code
@end
