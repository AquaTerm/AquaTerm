//
//  AQTModel.m
//  AquaTerm
//
//  Created by per on Fri Nov 02 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import "AQTModel.h"
#import "AQTColorMap.h"

@implementation AQTModel
/**"
*** A class representing a collection of objects making up the plot.
*** The objects can be leaf object like GPTPath and GPTLabel or a
*** collection itself (not exploited at present).
"**/

-(id)initWithSize:(NSSize)size
{
  self = [super init];
  if (self)
  {
    modelObjects = [[NSMutableArray alloc] initWithCapacity:0];
    [self setTitle:@"Untitled"];
    canvasSize = size;
  }
  return self;
}

-(void)dealloc
{
  [title release];
  [modelObjects release];
  [super dealloc];
}

-(int)count
{
  return [modelObjects count];
}

-(NSRect)bounds
{
  NSRect trackingRect = NSMakeRect(0,0,0,0);
  AQTGraphic *graphic;
  NSEnumerator *enumerator = [modelObjects objectEnumerator];

  while ((graphic = [enumerator nextObject]))
  {
    trackingRect = NSUnionRect(trackingRect, [graphic bounds]);
  }
  return trackingRect;
}

/**"
*** Add any subclass of AQTGraphic to the collection of objects.
"**/
-(void)addObject:(AQTGraphic *)graphic
{
  [graphic setCanvasSize:[self canvasSize]];
  [modelObjects addObject:graphic];
}

-(void)removeObject:(AQTGraphic *)graphic
{
  [modelObjects removeObject:graphic];
}

-(void)removeObjectsInRect:(NSRect)targetRect
{
  AQTGraphic *graphic;
  NSEnumerator *enumerator = [modelObjects objectEnumerator];

  while ((graphic = [enumerator nextObject]))
  {
    [graphic removeObjectsInRect:targetRect];	// recursively remove objects
    if (NSContainsRect(targetRect, [graphic bounds]))
    {
      [self removeObject:graphic];
    }
  }
}


/**"
*** Tell every object in the collection to draw itself.
"**/
-(void)renderInRect:(NSRect)boundsRect
{
  AQTGraphic *graphic;
  NSEnumerator *enumerator = [modelObjects objectEnumerator];

  while ((graphic = [enumerator nextObject]))
  {
    [graphic renderInRect:boundsRect];
  }
}

-(void)setColormap:(AQTColorMap *)newColorMap
{
  [newColorMap retain];
  [modelColorMap release];
  modelColorMap = newColorMap;
}
-(AQTColorMap *)colormap
{
  return modelColorMap;
}

-(void)setTitle:(NSString *)newTitle
{
  [newTitle retain];
  [title release];
  title = newTitle;
}

-(NSString *)title
{
  return [title copy];
}


// -- updateColors: --
// 	override parent class' implementation
-(void) updateColors:(AQTColorMap *)colorMap;
{
  AQTGraphic *graphic;
  NSEnumerator *enumerator = [modelObjects objectEnumerator];

  [self setColormap: colorMap]; // Remember map for inspector! PP
  while ((graphic = [enumerator nextObject]))
  {
    [graphic updateColors:colorMap];
  }
}

// ---- Timing for adapter testing -----
-(double)timeTaken
{
  return timeTaken;
}

-(void)setTimeTaken:(double)timer
{
  timeTaken = timer;
}


@end
