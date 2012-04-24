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
  AQTSize s;
  AQTRect r;

  [super encodeWithCoder:coder];
  [coder encodeObject:modelObjects];
  [coder encodeObject:title];
  // 64bit compatibility
  s.width = canvasSize.width; s.height = canvasSize.height;
  [coder encodeValueOfObjCType:@encode(AQTSize) at:&s];
  r.origin.x = dirtyRect.origin.x; r.origin.x = dirtyRect.origin.y;
  r.size.width = dirtyRect.size.width; r.size.height = dirtyRect.size.height;
  [coder encodeValueOfObjCType:@encode(AQTRect) at:&r];
  [coder encodeValueOfObjCType:@encode(BOOL) at:&isDirty];
}

-(id)initWithCoder:(NSCoder *)coder
{
  AQTSize s;
  AQTRect r;

  self = [super initWithCoder:coder];
  modelObjects = [[coder decodeObject] retain];
  title = [[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(AQTSize) at:&s];
  canvasSize.width = s.width; canvasSize.height = s.height;
  [coder decodeValueOfObjCType:@encode(AQTRect) at:&r];
  dirtyRect.origin.x = r.origin.x; dirtyRect.origin.x = r.origin.y;
  dirtyRect.size.width = r.size.width; dirtyRect.size.height = r.size.height;
  [coder decodeValueOfObjCType:@encode(BOOL) at:&isDirty];

  return self;
}

-(NSString *)description
{
   return [NSString stringWithFormat:@"[AQTModel description] =\nTitle %@\nCanvasSize %@\nCount %d\nBounds %@", title, NSStringFromSize(canvasSize), [modelObjects count],  NSStringFromRect(_bounds)];
}

 -(NSSize)canvasSize
 {
    return canvasSize;
 }

 -(void)setCanvasSize:(NSSize)cs
 {
    canvasSize = cs;
 }

-(BOOL)isDirty
{
   return isDirty;
}

-(NSRect)dirtyRect
{
   return dirtyRect;
}


-(int32_t)count
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

-(void)removeObjectAtIndex:(uint32_t)i
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
