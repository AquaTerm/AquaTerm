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
     linewidth = .2;
     hasPattern = NO;
  }
  return self;
}

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
  [coder encodeValueOfObjCType:@encode(BOOL) at:&isFilled];
  [coder encodeValueOfObjCType:@encode(int) at:&lineCapStyle];
  [coder encodeValueOfObjCType:@encode(float) at:&linewidth];
  [coder encodeValueOfObjCType:@encode(int) at:&pointCount];
  [coder encodeArrayOfObjCType:@encode(NSPoint) count:pointCount at:path];
  [coder encodeValueOfObjCType:@encode(int) at:&patternCount];
  [coder encodeArrayOfObjCType:@encode(float) count:patternCount at:pattern];
  [coder encodeValueOfObjCType:@encode(float) at:&patternPhase];
  [coder encodeValueOfObjCType:@encode(BOOL) at:&hasPattern];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  [coder decodeValueOfObjCType:@encode(BOOL) at:&isFilled];
  [coder decodeValueOfObjCType:@encode(int) at:&lineCapStyle];
  [coder decodeValueOfObjCType:@encode(float) at:&linewidth];
  [coder decodeValueOfObjCType:@encode(int) at:&pointCount];
  // path might be malloc'd or on heap depending on pointCount
  pointCount = [self _aqtSetupPathStoreForPointCount:pointCount];
  [coder decodeArrayOfObjCType:@encode(NSPoint) count:pointCount at:path]; 
  [coder decodeValueOfObjCType:@encode(int) at:&patternCount];
  [coder decodeArrayOfObjCType:@encode(float) count:patternCount at:pattern];
  [coder decodeValueOfObjCType:@encode(float) at:&patternPhase];
  [coder decodeValueOfObjCType:@encode(BOOL) at:&hasPattern];
  
  return self;
}

- (void)setLinestylePattern:(const float *)newPattern count:(int)newCount phase:(float)newPhase 
{
  // Create a local copy of the pattern.
   int i;
   if (newCount <= 0) // Sanity check
      return;
   // constrain count to MAX_PATTERN_COUNT
   newCount = newCount>MAX_PATTERN_COUNT?MAX_PATTERN_COUNT:newCount;
   for (i=0; i<newCount; i++) {
      pattern[i] = newPattern[i]; 
   }
   patternCount = newCount;
   patternPhase = newPhase;
   hasPattern = YES;
}

- (void)setLinewidth:(float)lw
{
  linewidth = lw;
}

- (void)setLineCapStyle:(int)capStyle
{
  lineCapStyle = capStyle;
}

- (void)setIsFilled:(BOOL)flag
{
   isFilled = flag;
}

- (BOOL)isFilled
{
   return isFilled;
}

- (BOOL)hasPattern
{
   return hasPattern;
}
@end
