//
//  AQTPath.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTPath.h"
#import "AQTColorMap.h"

@implementation AQTPath
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/
-(id)initWithPath:(NSBezierPath *)aPath filled:(BOOL)fill color:(NSColor *)aColor colorIndex:(int)cIndex indexedColor:(BOOL)icFlag
{
  if (self = [super init])
  {
    if (fill)
    {
      isFilled = YES;
      [path closePath];
    }
    path = [[NSBezierPath bezierPath] retain];
    [path appendBezierPath:aPath];
    [path setLineWidth:[aPath lineWidth]];
    colorIndex = cIndex;
    hasIndexedColor = icFlag;
    if (!hasIndexedColor)
    {
      [self setColor:aColor];
    }
  }
  return self; 
}


-(id)initWithPolyline:(NSBezierPath *)aPath colorIndex:(int)cIndex
{
  return [self initWithPath:aPath filled:NO color:nil colorIndex:cIndex indexedColor:YES];  
}

-(id)initWithPolygon:(NSBezierPath *)aPath colorIndex:(int)cIndex
{
  return [self initWithPath:aPath filled:YES color:nil colorIndex:cIndex indexedColor:YES];
}

-(id)initWithPolygon:(NSBezierPath *)aPath color:(NSColor *)aColor
{
  return [self initWithPath:aPath filled:YES color:aColor colorIndex:0 indexedColor:NO];
}

-(id)initWithPolyline:(NSBezierPath *)aPath color:(NSColor *)aColor
{
  return [self initWithPath:aPath filled:NO color:aColor colorIndex:0 indexedColor:NO]; 
}


-(void)dealloc
{
    [path release];
    [super dealloc];
}

-(NSRect)bounds
{
  NSRect tempBounds = [path bounds];
  if (NSIsEmptyRect(tempBounds))
  {
    /* Bounds need to be non-empty */
    tempBounds = NSInsetRect(tempBounds, -FLT_MIN, -FLT_MIN);
  }
  return tempBounds;
}

// override superclass' def of updateColors:
-(void)updateColors:(AQTColorMap *)colorMap
{
   if (hasIndexedColor)
   {	// Always brace in if-contructs!
      [self setColor:[colorMap colorForIndex:colorIndex]];
   }
}

@end
