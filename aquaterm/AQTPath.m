//
//  AQTPath.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "AQTPath.h"
#import "GPTColorExtras.h"

@implementation AQTPath
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/
-(id)initWithPath:(NSBezierPath *)aPath filled:(BOOL)fill color:(float)gray colorIndex:(int)cIndex indexedColor:(BOOL)icFlag
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
    mappedColor = gray;
    indexedColor = cIndex;
    hasIndexedColor = icFlag;
    
    if (hasIndexedColor)
    {
      [self setColor:[NSColor getColorFromIndex:indexedColor]];	
    }
    else
    {
      [self setColor:[NSColor interpolateColorFrom:[NSColor yellowColor] to:[NSColor redColor] by:mappedColor]];	
    }
  }
  return self; 
}

-(id)initWithPolyline:(NSBezierPath *)aPath color:(float)gray
{
  return [self initWithPath:aPath filled:NO color:gray colorIndex:-3 indexedColor:NO]; 
}

-(id)initWithPolyline:(NSBezierPath *)aPath colorIndex:(int)cIndex
{
  return [self initWithPath:aPath filled:NO color:0.5 colorIndex:cIndex indexedColor:YES];  
}

-(id)initWithPolygon:(NSBezierPath *)aPath color:(float)gray
{
  return [self initWithPath:aPath filled:YES color:gray colorIndex:-3 indexedColor:NO];
}

-(id)initWithPolygon:(NSBezierPath *)aPath colorIndex:(int)cIndex
{
  return [self initWithPath:aPath filled:YES color:0.5 colorIndex:cIndex indexedColor:YES];
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

-(void)renderInRect:(NSRect)boundsRect
{
    NSSize docSize = NSMakeSize(842,595); // FIXME!!! Should refer to document size instead
    NSAffineTransform *localTransform = [NSAffineTransform transform];
    float xScale = boundsRect.size.width/docSize.width;
    float yScale = boundsRect.size.height/docSize.height;
    //
    // Get the transform due to view resizing
    //
    [localTransform scaleXBy:xScale yBy:yScale];
    [color set];
    if (isFilled)
    {
      [[localTransform transformBezierPath:path] fill];
    }
    [[localTransform transformBezierPath:path] stroke];	// FAQ: Needed unless we holes in the surface? 
}

@end
