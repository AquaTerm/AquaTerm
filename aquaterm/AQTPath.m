//
//  AQTPath.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTPath.h"
@implementation AQTPath

/*" A private method to provide storage for an NSPointArray "*/
- (int)_aqtSetupPathStoreForPointCount:(int)pc
{
   // Use static store as default (efficient for small paths)
   path = staticPathStore;
   if (pc > STATIC_POINT_STORAGE)
   {
      // Use dynamic store instead to avoid large memory overhead
      // by having too large static store in all objects
      if(dynamicPathStore = malloc(pc * sizeof(NSPoint)))
      {
         path = dynamicPathStore;
      }
      else
      {
         NSLog(@"Error: Could not allocate memory, path clipped to %d points", STATIC_POINT_STORAGE);
         pc = STATIC_POINT_STORAGE;
      }
   }
   return pc;
}

/**"
*** A leaf object class representing an actual item in the plot.
*** Since the app is a viewer we do three things with the object:
*** create (once), draw (any number of times) and (eventually) dispose of it.
"**/
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pc;
{
  int i;
  if (self = [super init])
  {
     pc = [self _aqtSetupPathStoreForPointCount:pc];
     // FIXME: memcpy
     for (i = 0; i < pc; i++)
     {
        path[i] = points[i];
     }
     pointCount = pc;
     [self setLinewidth:.2];
  }
  return self;
}
/*
// NOTE: this is a _second_ designated(?) initializer....
- (id)initWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc;
{
   int i;
   if (self = [super init])
   {
      pc = [self _aqtSetupPathStoreForPointCount:pc];
      // FIXME: memcpy
      for (i = 0; i < pc; i++)
      {
         path[i] = NSMakePoint(x[i], y[i]);
      }
      pointCount = pc;
      [self setLinewidth:.2];
   }
   return self;
}
*/
-(id)init
{
  return [self initWithPoints:nil pointCount:0];
}

-(void)dealloc
{
  if (path == dynamicPathStore)
  {
     free(dynamicPathStore);
  }
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
  [coder encodeValueOfObjCType:@encode(int) at:&lineCapStyle];
  [coder encodeValueOfObjCType:@encode(float) at:&linewidth];
  [coder encodeValueOfObjCType:@encode(int) at:&pointCount];
  [coder encodeArrayOfObjCType:@encode(NSPoint) count:pointCount at:path]; 
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  [coder decodeValueOfObjCType:@encode(int) at:&lineCapStyle];
  [coder decodeValueOfObjCType:@encode(float) at:&linewidth];
  [coder decodeValueOfObjCType:@encode(int) at:&pointCount];
  // path might be malloc'd or on heap depending on pointCount
  pointCount = [self _aqtSetupPathStoreForPointCount:pointCount];
  [coder decodeArrayOfObjCType:@encode(NSPoint) count:pointCount at:path]; 
  return self;
}

- (void)setLinewidth:(float)lw
{
  linewidth = lw;
}
- (void)setLineCapStyle:(int)capStyle
{
  lineCapStyle = capStyle;
}
@end
