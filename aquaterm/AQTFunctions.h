//
//  AQTFunctions.h
//  AquaTerm
//
//  Created by Per Persson on Tue Nov 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/NSGeometry.h>
#import "AQTGraphic.h"

/* Color utilities */
static inline BOOL AQTEqualColors(AQTColor c1, AQTColor c2){
   return (c1.red == c2.red && c1.green == c2.green && c1.blue == c2.blue);}

/* Geometry extensions */
static inline BOOL AQTIntervalContainsFloat(float aMin, float aMax, float a){
   return (a > aMin && a < aMax);}
static inline BOOL AQTIsZeroRect(NSRect aRect){
   return NSEqualRects(aRect, NSZeroRect);}
BOOL AQTContainsRect(NSRect containerRect, NSRect testRect);
BOOL AQTIntersectsRect(NSRect aRect, NSRect bRect);
NSRect AQTUnionRect(NSRect aRect, NSRect bRect);
NSRect AQTRectFromSize(NSSize aSize);



