//
//  AQTModel.m
//  AquaTerm
//
//  Created by per on Fri Nov 02 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import "AQTModel.h"

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
    modelObjects = [[NSMutableArray alloc] initWithCapacity:1024];
    [self setTitle:@"Untitled"];
    canvasSize = size;
  }
  return self;
}

-(id)init
{
  return [self initWithSize:NSMakeSize(200,200)];
}

-(void)dealloc
{
  [title release];
  [modelObjects release];
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
  [coder encodeObject:modelObjects];
  [coder encodeObject:title];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  modelObjects = [[coder decodeObject] retain];
  title = [[coder decodeObject] retain];
  return self;
}

-(void)setSize:(NSSize)size
{
  canvasSize = size;
}

-(NSSize)size
{
   return canvasSize;
}

-(int)count
{
  return [modelObjects count];
}

/*
-(NSRect)recomputeBounds
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
*/
/**"
*** Add any subclass of AQTGraphic to the collection of objects.
"**/
-(void)addObject:(AQTGraphic *)graphic
{
  [graphic setCanvasSize:[self canvasSize]];
  [modelObjects addObject:graphic];
  [self setBounds:NSUnionRect([self bounds], [graphic bounds])];
}

-(void)removeObjectsInRect:(NSRect)targetRect
{
  // FIXME: It is possible to recursively nest models in models,
  // but this method doesn't work in that case

  NSRect testRect;
  int i;
  int  objectCount = [modelObjects count];

  NSDate *startTime=  [NSDate date];

  targetRect = NSInsetRect(targetRect, -0.5, -0.5); // Try to be smart...

  if(objectCount == 0)
    return;

  if (NSContainsRect(targetRect, [self bounds]))
  {
    [modelObjects removeAllObjects];
    [self setBounds:NSZeroRect];
  }
  else
  {
    for (i = objectCount - 1; i >= 0; i--)
    {
      testRect = [[modelObjects objectAtIndex:i] bounds];
      if (testRect.size.height == 0.0 || testRect.size.width == 0.0)
      {
        testRect = NSInsetRect(testRect, -0.1, -0.1); // FIXME: Try to be smarter...
      }
      if (NSContainsRect(targetRect, testRect))
      {
        [modelObjects removeObjectAtIndex:i];
      }
      else
      {
        // FIXME: Rebuild bounds (not verified!)
        [self setBounds:NSUnionRect([self bounds], testRect)];
      }
    }
  }
  NSLog(@"Time taken: %f", -[startTime timeIntervalSinceNow]);
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

@end
