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
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pc filled:(BOOL)fill color:(NSColor *)aColor colorIndex:(int)cIndex indexedColor:(BOOL)icFlag
{
   int i;
   if (self = [super init])
   {
      for (i = 0; i < pc; i++)
      {
         path[i] = points[i];
      }
      if (fill)
      {
         isFilled = YES;
      }
      colorIndex = cIndex;
      hasIndexedColor = icFlag;
      if (!hasIndexedColor)
      {
         [self setColor:aColor];
      }
   }
   return self;
}

-(id)init
{
   return [self initWithPoints:nil pointCount:0 filled:NO color:[NSColor blackColor] colorIndex:1 indexedColor:YES];
}

-(void)dealloc
{
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   int i;
   [super encodeWithCoder:coder];
   [coder encodeValueOfObjCType:@encode(BOOL) at:&hasIndexedColor];
   [coder encodeValueOfObjCType:@encode(BOOL) at:&isFilled];
   [coder encodeValueOfObjCType:@encode(int) at:&pointCount];
   for (i=0;i<pointCount;i++)
   {
      [coder encodeValueOfObjCType:@encode(NSPoint) at:&path[i]];      
   }
}

-(id)initWithCoder:(NSCoder *)coder
{
   int i;
   self = [super initWithCoder:coder];
   [coder decodeValueOfObjCType:@encode(BOOL) at:&hasIndexedColor];
   [coder decodeValueOfObjCType:@encode(BOOL) at:&isFilled];
   [coder decodeValueOfObjCType:@encode(int) at:&pointCount];
   for (i=0;i<pointCount;i++)
   {
      [coder decodeValueOfObjCType:@encode(NSPoint) at:&path[i]];
   }
   return self;
}

-(void)addPoint:(NSPoint)aPoint
{
   path[pointCount]=aPoint;
   pointCount++;
}

-(NSRect)bounds
{
   NSRect tempBounds = NSMakeRect(10, 10, 10, 10); //[path bounds];
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
   {	
      [self setColor:[colorMap colorForIndex:colorIndex]];
   }
}

@end
