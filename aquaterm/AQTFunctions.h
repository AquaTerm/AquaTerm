//
//  AQTFunctions.h
//  AquaTerm
//
//  Created by Per Persson on Tue Nov 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/NSGeometry.h>
#import "AQTGraphic.h"

#define COMP_EPS 0.001

// A macro to cast structs that have the same fields 
// Handy, dangerous and untested...
#define CAST_STRUCT_TO(struct_t) *(struct_t *)&

// FIXME: test these...
#define GEQ(a,b) ((a) > (b)-COMP_EPS)
#define LEQ(a,b) ((a) < (b)+COMP_EPS)
#define EQ(a,b) (-COMP_EPS < (a)-(b) && (a)-(b) < COMP_EPS)

/* Color utilities */
static inline BOOL AQTEqualColors(AQTColor c1, AQTColor c2) {
   // return (c1.red == c2.red && c1.green == c2.green && c1.blue == c2.blue);
   return (EQ(c1.red, c2.red) && EQ(c1.green, c2.green) && EQ(c1.blue, c2.blue) && EQ(c1.alpha, c2.alpha));
}

/* Geometry extensions */
static inline BOOL AQTIntervalContainsFloat(float aMin, float aMax, float a) {
   // return (a > aMin - COMP_EPS  && a < aMax + COMP_EPS);
   return (GEQ(a, aMin)  && LEQ(a, aMax));
}

static inline BOOL AQTIsZeroRect(NSRect aRect){
   return NSEqualRects(aRect, NSZeroRect);
}
BOOL AQTContainsRect(NSRect containerRect, NSRect testRect);
BOOL AQTIntersectsRect(NSRect aRect, NSRect bRect);
NSRect AQTUnionRect(NSRect aRect, NSRect bRect);
static inline NSRect AQTRectFromSize(NSSize aSize) {
   return NSMakeRect(0.0, 0.0, aSize.width, aSize.height);
}
static inline BOOL AQTProportionalSizes(NSSize aSize, NSSize bSize) {
   return EQ(aSize.height/aSize.width, bSize.height/bSize.width);
}



