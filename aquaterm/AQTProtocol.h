//
// Since this header file is used outside of AquaTerm too,
// the internal version number is defined explicitly here
//
/* Constants that define useful foo. */
#define AQTProtocolVersion 0.3.0

@protocol AQTProtocol
/* AQTProtocol */

/*" State-changing methods "*/

- (oneway void)openModel:(int)newModel;
/* openModel: */
- (oneway void)closeModel;
/* closeModel: */

/*" Methods available in both open and closed state "*/

- (bycopy NSDictionary *) getAquaTermInfo;
/*
Return a dictionary containing useful information such as
version number string for AquaTerm in the form #.#.#
corresponding to major_version.minor_version.bugfix_version
as well as user settings such as canvas size, default font etc.

The following dictionary keys are valid:
_{AQTVersion					version number string for AquaTerm in the form #.#.#}
_{AQTXMax						x-size of canvas in points (1/72 inch)}
_{AQTYMax						y-size of canvas in points (1/72 inch)}
_{AQTFontWHRatio			ratio of fontWidth to fontHeight}
_{AQTPixelWHRatio		ratio of pixel with to height on device (always 1.0 for now)}
_{AQTDefaultFontName	default font (Times Roman)}
_{AQTDefaultFontSize	default font size (16p)}
_{AQTFontName				current font}
_{AQTFontSize				current font size}
*/

- (oneway void) setFontWithName:(bycopy NSString *)fontName size:(bycopy float)fontSize;
/*
Set the font for the subsequent strings added to the model
(mimics fontWithName: size: method in NSFont)
*/

-(oneway void)setColor:(NSColor *)aColor forIndex:(int)colorIndex;
/* Set the NSColor for a particular entry in the colormap. */

/*" Methods available only in open state "*/

- (oneway void) addString:(bycopy NSString *)text
                  atPoint:(bycopy NSPoint)point
        withJustification:(bycopy int)justification
                  atAngle:(bycopy float)angle
         withIndexedColor:(bycopy int)colorIndex;
  /*
   Add a string to the current model, where:
   justification is
   _{justification value}
   _{LEFT 0}
   _{CENTER 1}
   _{RIGHT 2}
   colorIndex is a number in the range -4 and upwards.
   Indices 0 and upwards points to an entry in the colormap.
   The colors -4, ..., -1 have special meanings as follows:
   _{colorIndex meaning}
   _{-1 Grid color}
   _{-2 Axis color}
   _{-3 Reserved}
   _{-4 Background color}
   By following the (optional) special indexing scheme above, those colors will be availble to
   the Inspector window in addition to the foreground colors.
   Any cyclic color behaviour have to be taken care of in the client adapter.
   */

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
/* Add a raw bitmap (unsigned char) with each byte corresponding to an entry in the indexed colormap */

- (oneway void) addImage:(bycopy NSData *)imageData  bounds:(NSRect)theBounds;
/*
*** Obsolete, will go away in next official release *** 
Add an image. The imageData must be such that an NSImage can be created from:
NSImage *anImage = [[NSImage alloc] initWithData:imageData];
*/

- (oneway void) addImageFromFile:(bycopy NSString *)filename;
/*  Add an image from file, given a valid filename. (TIFF, jpg, etc.) */

- (oneway void)render;
/*  Render the model _without_ closing it */

-(oneway void) clearRect:(NSRect)rect;
/*  remove all objects found _completely_ contained in rect */

//
//	---- Deprecated methods, will disappear as of AQTProtocol 0.4.0 ----
//

/*" The following methods are deprecated as of AQTProtocol version 0.3.0 and will disappear as of AQTProtocol 0.4.0. For the sake of backwards compatibility with the old adapters using them, they are mapped to appropriate methods.

For the addPolyline:withColor: and addPolygon:withColor: methods this will unfortunately lead to a greyscale representation, most notable with the 'pm3d' option in gnuplot. Updating the adapters will resolve the problem.  
"*/
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color;
/* Deprecated. Add a bezierpath with greyscale color to the model */
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color;
/* Deprecated. Add a closed, filled bezierpath with greyscale color to the model */

- (oneway void) selectModel:(int) currentModel;
/* Deprecated. Select the model that will receive subsequent graphic elements */

- (oneway void) renderInViewShouldRelease:(BOOL)release;
/*
Deprecated. Render the current model, argument is normally YES unless
this is part of a multiplot operation with subsequent
drawing to the same model
*/
@end
