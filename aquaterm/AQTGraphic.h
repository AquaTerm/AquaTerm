//
//  AQTGraphic.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
// Aiming at removing AppKit reliance from model code
#import <AppKit/AppKit.h>

@class AQTColorMap, AQTModel;

@interface AQTGraphic : NSObject <NSCoding>
{
    NSColor *color;
  /* hasIndexedColor should be part of the subclasses that have an option! */
    int colorIndex;	  /*" Could mean color or linestyle (dash) depending on graphic object "*/
    NSSize canvasSize;
}

/*" accessor methods "*/
-(NSSize)canvasSize;
-(void)setCanvasSize:(NSSize)cs;
-(NSRect)bounds;
-(void)addObject:(AQTGraphic *)graphic;
-(void)removeObject:(AQTGraphic *)graphic;
-(void)removeObjectsInRect:(NSRect)targetRect;

/*" color handling "*/
-(NSColor *)color;
-(void)setColor:(NSColor *)newColor;
-(void)updateColors:(AQTColorMap *)colorMap; // the new color handling code
@end
