//
//  AQTFunctions.m
//  AquaTerm
//
//  Created by Per Persson on Tue Nov 25 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTFunctions.h"

BOOL AQTContainsRect(NSRect containerRect, NSRect testRect)
{
   BOOL contains = NO;

   if (NSIsEmptyRect(testRect) == NO)
   {
      contains = NSContainsRect(containerRect, testRect);
   }
   else
   {
      if (EQ(NSWidth(testRect), 0.0))
      {
         contains = (NSMaxY(testRect) < NSMaxY(containerRect)) && (NSMinY(testRect) > NSMinY(containerRect));
      }
      else
      {
         contains = (NSMaxX(testRect) < NSMaxX(containerRect)) && (NSMinX(testRect) > NSMinX(containerRect));
      }
   }
   return contains;
}

BOOL AQTIntersectsRect(NSRect aRect, NSRect bRect)
{
   BOOL intersects = NO;
   BOOL aRectIsEmpty = NSIsEmptyRect(aRect);
   BOOL bRectIsEmpty = NSIsEmptyRect(bRect);

   if (!aRectIsEmpty && !bRectIsEmpty) 
      return NSIntersectsRect(aRect, bRect);

   if (aRectIsEmpty && bRectIsEmpty)
      return NO;

   // Either aRect _or_ bRect is empty 
   if(aRectIsEmpty)
   {
      // Swizzle aRect and bRect
      NSRect tmp = aRect;
      aRect = bRect;
      bRect = tmp;
   }
   // bRect is empty
   if (EQ(NSWidth(bRect),0.0))
   {
      // bRect is a vertical line
      intersects =
      AQTIntervalContainsFloat(NSMinX(aRect), NSMaxX(aRect), NSMinX(bRect)) &&
      (AQTIntervalContainsFloat(NSMinY(bRect), NSMaxY(bRect), NSMinY(aRect)) ||
       AQTIntervalContainsFloat(NSMinY(bRect), NSMaxY(bRect), NSMaxY(aRect)) ||
       AQTIntervalContainsFloat(NSMinY(aRect), NSMaxY(aRect), NSMaxY(bRect)));
   }
   else
   {
      // bRect is a horizontal line
      intersects =
      AQTIntervalContainsFloat(NSMinY(aRect), NSMaxY(aRect), NSMinY(bRect)) &&
      (AQTIntervalContainsFloat(NSMinX(bRect), NSMaxX(bRect), NSMaxX(aRect)) || /* crosses right edge*/
       AQTIntervalContainsFloat(NSMinX(bRect), NSMaxX(bRect), NSMinX(aRect)) || /* crosses left edge*/
       AQTIntervalContainsFloat(NSMinX(aRect), NSMaxX(aRect), NSMinX(bRect)));  /* inside, either both endpoints or none */
   }
   return intersects;
}

NSRect AQTUnionRect(NSRect aRect, NSRect bRect)
{
   if (AQTIsZeroRect(aRect) || AQTIsZeroRect(bRect) || NSEqualRects(aRect, bRect))
      return AQTIsZeroRect(aRect)?bRect:aRect;
   else
   {
      float x = MIN(NSMinX(aRect), NSMinX(bRect));
      float y = MIN(NSMinY(aRect), NSMinY(bRect));
      float w = MAX(NSMaxX(aRect), NSMaxX(bRect)) - x;
      float h = MAX(NSMaxY(aRect), NSMaxY(bRect)) - y;

      return NSMakeRect(x, y, w, h);
   }
}

