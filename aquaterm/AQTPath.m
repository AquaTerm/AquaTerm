//
//  AQTPath.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTPath.h"

@implementation AQTPath
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pc filled:(BOOL)fill color:(AQTColor)aColor
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
      [self setColor:aColor];
   }
   return self;
}

-(id)init
{
   AQTColor tCol;
   tCol.red = 1.0;
   tCol.green = 0.0;
   tCol.blue = 1.0;
   return [self initWithPoints:nil pointCount:0 filled:NO color:tCol];
}

-(void)dealloc
{
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   int i;
   [super encodeWithCoder:coder];
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
@end
