//
// Since this header file is used outside of AquaTerm too,
// the internal version number is defined explicitly here
//
#define AQTProtocolVersion 0.2.0

@protocol AQTProtocol
//
// Return a version number string for AquaTerm in the form #.#.#
// corresponding to major_version.minor_version.bugfix_version
//
- (bycopy NSDictionary *) getAquaTermInfo;
//
// Render the current model, argument is normally YES unless
// this is part of a multiplot operation with subsequent 
// drawing to the same model
//
- (oneway void) renderInViewShouldRelease:(BOOL)release;
//
// Add a string to the current model, where:
// justification is {LEFT=0, CENTER, RIGHT}
// colorIndex is a number in the range -3 and upwards
// The colors -3, -2, -1 have special meaning and 
// colors 0 and upwards are taken modulo N (i.e cyclic)
//
- (oneway void) addString:(bycopy NSString *)text 
                  atPoint:(bycopy NSPoint)point 
        withJustification:(bycopy int)justification 
                  atAngle:(bycopy float)angle		
         withIndexedColor:(bycopy int)colorIndex;
//
// Set the font for the subsequent strings added to the model
// (mimics fontWithName: size: method in NSFont)
//                  
- (oneway void) setFontWithName:(bycopy NSString *)fontName size:(bycopy float)fontSize;
//
// Add graphic elements to the model. A "polyline" refers to any 
// collection of line segments etc. whereas "polygon" refers to a 
// closed surface. (Q: confusing naming scheme?)
// IndexedColor has the same meaning as for addString and
// color is number between 0 and 1 corresponding to an interpolation
// between two colors. 
//
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex;
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color;
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex;
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color;
//
// Select the model that will receive subsequent graphic elements
// (Q: What does this imply for the corresponding window? Front? Show? Key?
//  A: Definitely "show" and absolutely _not_ "front", "key" is meaningless)
// 
- (oneway void) selectModel:(int) currentModel;
@end
