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
"**/

-(id)initWithCanvasSize:(NSSize)size
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
  return [self initWithCanvasSize:NSMakeSize(200,200)];
}

-(void)dealloc
{
#ifdef MEM_DEBUG
   NSLog(@"[%@(0x%x) %@] %s:%d", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), __FILE__, __LINE__);
#endif
   [title release];
   [modelObjects release];
   [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
  [coder encodeObject:modelObjects];
  [coder encodeObject:title];
  [coder encodeValueOfObjCType:@encode(NSSize) at:&canvasSize];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  modelObjects = [[coder decodeObject] retain];
  title = [[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(NSSize) at:&canvasSize];
  return self;
}


 -(NSSize)canvasSize
 {
    return canvasSize;
 }

 -(void)setCanvasSize:(NSSize)cs
 {
    canvasSize = cs;
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
  [modelObjects addObject:graphic];
}

-(void)addObjectsFromArray:(NSArray *)graphics
{
   [modelObjects addObjectsFromArray:graphics];   
}

-(NSArray *)modelObjects
{
   return modelObjects;
}

-(void)removeAllObjects
{
   [modelObjects removeAllObjects];
}

-(void)removeObjectAtIndex:(unsigned)i
{
   [modelObjects removeObjectAtIndex:i];
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
