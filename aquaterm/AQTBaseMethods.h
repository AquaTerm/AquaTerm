//
// Since this header file is used outside of AquaTerm too,
// the internal version number is defined explicitly here
//
#define AQTBaseMethodsVersion 0.3.1

@protocol AQTBaseMethods
/* AQTBaseMethods */

/*" State-changing methods "*/

- (oneway void)openModel:(int)newModel;
/* openModel: */
- (oneway void)openModel:(int)newModel size:(NSSize)canvasSize;
/* openModel:size: */
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

- (oneway void)setTitle:(bycopy NSString *)newTitle;
/* Set the title for the current model, defaults to 'Figure n'. */

- (oneway void) setFontWithName:(bycopy NSString *)fontName size:(bycopy float)fontSize;
/*
Set the font for the subsequent strings added to the model
(mimics fontWithName: size: method in NSFont)
*/

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

- (oneway void)render;
/*  Render the model _without_ closing it */

-(oneway void) clearRect:(NSRect)rect;
/*  remove all objects found _completely_ contained in rect */

@end
