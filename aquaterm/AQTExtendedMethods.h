//
// Since this header file is used outside of AquaTerm too,
// the internal version number is defined explicitly here
//
#define AQTExtendedMethodsVersion 0.3.1

@protocol AQTExtendedMethods
/* AQTBaseMethods */

/*" Methods available only in open state "*/

// ADDME!
- (oneway void) addAttributedString:(bycopy NSAttributedString *)text
                            atPoint:(bycopy NSPoint)point
                  withJustification:(bycopy int)justification
                            atAngle:(bycopy float)angle;
  /*
   Add a an attributed string to the current model, where:
   justification is
   _{justification value}
   _{LEFT 0}
   _{CENTER 1}
   _{RIGHT 2}
   */

-(oneway void)setColor:(bycopy NSColor *)aColor forIndex:(int)colorIndex;
/* Set the NSColor for a particular entry in the colormap. */

// ADDME! 
//-(oneway void)setColormap:();

//
//  Add graphic elements to the model. A "polyline" refers to any
//  collection of line segments etc. whereas "polygon" refers to a
//  closed surface. (Q: confusing naming scheme?)
//  IndexedColor has the same meaning as for addString and
//  color is an NSColor object.
//
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex;
/* Add a bezierpath with color given by the current colormap to the model */
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex;
/* Add a polygon (filled bezierpath) with color given by the current colormap to the model */
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withRGBColor:(bycopy NSColor *)color;
/* Add a bezierpath, with the given color, to the model */
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withRGBColor:(bycopy NSColor *)color;
/* Add a polygon (filled bezierpath), with the given color, to the model */

- (oneway void) addBitmap:(bycopy NSData *)imageData size:(NSSize)theSize bounds:(NSRect)theBounds;
/* Add a bitmap (TIFFRepresentation) */

- (oneway void) addImageFromFile:(bycopy NSString *)filename bounds:(NSRect)theBounds;
/*  Add an image from file, given a valid filename. (TIFF, jpg, etc.) */
@end