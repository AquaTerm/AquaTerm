//
//  AQTPath.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTPath.h"

NSRect AQTExpandRectWithPoint(NSRect aRect, NSPoint aPoint)
{
  float minX = NSMinX(aRect);
  float maxX = NSMaxX(aRect);
  float minY = NSMinY(aRect);
  float maxY = NSMaxY(aRect);
  // NSRect may be zeroRect => make aPoint the origin
  if(NSEqualRects(aRect, NSZeroRect))
  {
    return NSMakeRect(aPoint.x, aPoint.y, 0.0, 0.0);
  }
  if (NSPointInRect(aPoint, aRect))
  {
    return aRect;
  }
  // We know aPoint lies outside aRect
  if (aPoint.x < minX)
  {
    minX = aPoint.x;
  }
  else if(aPoint.x > maxX)
  {
    maxX = aPoint.x;
  }
  if (aPoint.y < minY)
  {
    minY = aPoint.y;
  }
  else if(aPoint.y > maxY)
  {
    maxY = aPoint.y;
  }
  return NSMakeRect(minX, minY, maxX-minX, maxY-minY);
}

@implementation AQTPath
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pc color:(AQTColor)aColor
{
   int i;
   if (self = [super init])
   {
      for (i = 0; i < pc; i++)
      {
         path[i] = points[i];
        _bounds = AQTExpandRectWithPoint(_bounds, points[i]);
      }
      pointCount = pc;
     [self setLinewidth:.2];
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
   return [self initWithPoints:nil pointCount:0 color:tCol];
}

-(void)dealloc
{
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   int i;
   [super encodeWithCoder:coder];
   [coder encodeValueOfObjCType:@encode(float) at:&linewidth];
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
   [coder decodeValueOfObjCType:@encode(float) at:&linewidth];
   [coder decodeValueOfObjCType:@encode(int) at:&pointCount];
   for (i=0;i<pointCount;i++)
   {
      [coder decodeValueOfObjCType:@encode(NSPoint) at:&path[i]];
   }
   return self;
}

- (void)setLinewidth:(float)lw
{
  linewidth = lw;
}
@end
