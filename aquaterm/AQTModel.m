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

/**"
*** Add any subclass of AQTGraphic to the collection of objects.
"**/
-(void)addObject:(AQTGraphic *)graphic
{
  [graphic setCanvasSize:[self canvasSize]];
  [modelObjects addObject:graphic];
}

-(NSArray *)modelObjects
{
   return modelObjects;
}

-(void)removeAllModelObjects
{
   [modelObjects removeAllObjects];
}

-(void)setTitle:(NSString *)newTitle
{
  [newTitle retain];
  [title release];
  title = newTitle;
}

-(NSString *)title
{
  return [[title copy] autorelease];
}

@end
