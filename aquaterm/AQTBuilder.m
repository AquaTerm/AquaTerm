//
//  AQTBuilder.m
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AQTBuilder.h"
#import "AQTPath.h"
#import "AQTLabel.h"
#import "AQTModel.h"
#import "AQTImage.h"
#import "AQTColorMap.h"
#import "GPTController.h"

#import "GPTView.h"

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}
#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */

@implementation AQTBuilder
-(id)init
{
  if(self = [super init])
  {
	font = [[NSFont fontWithName:@"Times-Roman" size:16.0] retain];
    colormap = [[AQTColorMap alloc] init];	// Request the default colormap
    model = nil;	// Model _should_ be nil
  }
  return self;
}

- (void)dealloc
{
  [colormap release];
  [model release];
  [font release];
  [super dealloc];
}

-(void)setRenderer:(id)newRenderer
{
  renderer = newRenderer;
}
-(id)renderer
{
  return renderer;
}

//
// -----------------------------------------------------------------
//
// Implementation of the methods listed in the AQTProtocol protocol
//
// -----------------------------------------------------------------
//
// NB. Documentation of these methods go into AQTProtocol.mdoc
//

//
// ---- State-changing methods ----
//
- (oneway void)openModel:(int)newModel
{
  if (model)
  {
    LOG(@"Calling openModel: without closing previous model");
    [self closeModel];
  }
  model = [[AQTModel alloc] init];
  modelNumber = newModel;
}

- (oneway void)closeModel
{
  // Hand over model to renderer and release it
  [model updateColors:colormap];
  NSLog(@"builder/closeModel setmodel:forView:%d",index);

  [renderer setModel:model forView:modelNumber];	// the renderer will retain this object
  [model release];
  model = nil;
}

//
// ---- Methods available in both open and closed state ----
//
- (bycopy NSDictionary *)getAquaTermInfo
{
  //
  // FiXME: These are _app_ settings, not to be decided here!
  //
  NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:0];
  [tmpDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"AQTVersion"];
  [tmpDict setObject:[NSNumber numberWithFloat:AQUA_XMAX] forKey:@"AQTXMax"];
  [tmpDict setObject:[NSNumber numberWithFloat:AQUA_YMAX] forKey:@"AQTYMax"];
  [tmpDict setObject:[NSNumber numberWithFloat: 0.6] forKey:@"AQTFontWHRatio"];
  [tmpDict setObject:[NSNumber numberWithFloat: 1.0] forKey:@"AQTPixelWHRatio"];
  [tmpDict setObject:@"Times-Roman" forKey:@"AQTDefaultFontName"];
  [tmpDict setObject:[NSNumber numberWithFloat:16.0] forKey:@"AQTDefaultFontSize"];
  [tmpDict setObject:[font fontName] forKey:@"AQTFontName"];
  [tmpDict setObject:[NSNumber numberWithFloat:[font pointSize]] forKey:@"AQTFontSize"];
  return tmpDict;
}

// Set the font to be used.
- (oneway void)setFontWithName:(bycopy NSString *)newFontName size:(bycopy float)newFontSize
{
  NSFont *newFont;
  
  if ([[[NSFontManager sharedFontManager] availableFonts] containsObject:newFontName])
  {
    newFont = [NSFont fontWithName:newFontName size:newFontSize];
  }
  else
  {
    newFont = [NSFont systemFontOfSize:newFontSize];
  }
  [newFont retain];
  [font release];
  font = newFont;
}

-(oneway void)setColor:(NSColor *)aColor forIndex:(int)colorIndex
{
  [colormap setColor:aColor forIndex:colorIndex];
}


//
// ---- Methods available only in open state ----
//

// Add a string (label) to the model currently being built.
- (oneway void) addString:(bycopy NSString *)text
                  atPoint:(bycopy NSPoint)point
        withJustification:(bycopy int)justification
                  atAngle:(bycopy float)angle
         withIndexedColor:(bycopy int)colorIndex
{
  NSDictionary *attrs = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];

  AQTLabel *theLabel=[[AQTLabel alloc] initWithString:text
                                           attributes:attrs
                                             position:point
                                                angle:angle
                                        justification:justification
                                           colorIndex:colorIndex];
  [model addObject:theLabel];
  [theLabel release];

}

// Add a path to the model currently being built 
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
  AQTPath *thePath=[[AQTPath alloc] initWithPolyline:aPath colorIndex:colorIndex];
  [model addObject:thePath];
  [thePath release];
}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withIndexedColor:(bycopy int)colorIndex
{
  AQTPath *thePath=[[AQTPath alloc] initWithPolygon:aPath colorIndex:colorIndex];
  [model addObject:thePath];
  [thePath release];
}
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withRGBColor:(bycopy NSColor *)color
{
  AQTPath *thePath=[[AQTPath alloc] initWithPolyline:aPath color:color];
  [model addObject:thePath];
  [thePath release];
}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withRGBColor:(bycopy NSColor *)color
{
  AQTPath *thePath=[[AQTPath alloc] initWithPolygon:aPath color:color];
  [model addObject:thePath];
  [thePath release];
}

// Bitmap and image handling
- (oneway void) addBitmap:(bycopy NSData *)imageData  bounds:(NSRect)theBounds
{
}

- (oneway void) addImage:(bycopy NSData *)imageData  bounds:(NSRect)theBounds
{
  AQTImage *tempImage;
  NSImage *anImage = [[NSImage alloc] initWithData:imageData];
  [anImage setFlipped:YES];
  tempImage = [[AQTImage alloc] initWithImage:anImage];
  [tempImage setBounds:theBounds];
  [model addObject:tempImage];
  [tempImage release];
  [anImage release];
}

- (oneway void)addImageFromFile:(bycopy NSString *)filename
{
  AQTImage *tempImage = [[AQTImage alloc] initWithContentsOfFile:filename];
  [model addObject:tempImage];
  [tempImage release];
}

// Render the model _without_ closing it 
- (oneway void)render
{
  [model updateColors:colormap];	// Get all objects to set its own color before display
    NSLog(@"builder/render calling setmodel:forView:%d",index);

  [renderer setModel:model forView:modelNumber];	// the renderer will retain this object
}


// Clear part of the grap by removing every object _completely_ inside rect 
-(oneway void) clearRect:(NSRect)rect
{
  [model removeObjectsInRect:rect];
}

//
//	---- Deprecated methods, will disappear as of AQTProtocol 0.4.0 ----
// 

- (oneway void) selectModel:(int)currentModel
{
  LOG(@"Deprecated: selectModel:");
  if (nil != model && [model count] == 0)
  {
    // Due to the way the previous versions worked, just change model number :-(
    modelNumber = currentModel;
  }
  else
  {
    [self openModel:currentModel];
  }
}

- (oneway void) renderInViewShouldRelease:(BOOL)release
{
  LOG(@"Deprecated: renderInViewShouldRelease:");
  if (release)
  {
    [self closeModel];
    // Due to the way the previous versions worked, we'll have to re-open the model here :-(
    [self openModel:modelNumber];
  }
  else
  {
    [self render];
  }
}
- (oneway void) addPolyline:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
  LOG(@"Deprecated: addPolyline:withColor:");
  [self addPolyline:aPath withRGBColor:[NSColor colorWithCalibratedRed:color green:color blue:color alpha:1.0]];
}
- (oneway void) addPolygon:(bycopy NSBezierPath *)aPath withColor:(bycopy float)color
{
  LOG(@"Deprecated: addPolygon:withColor:");
  [self addPolygon:aPath withRGBColor:[NSColor colorWithCalibratedRed:color green:color blue:color alpha:1.0]];
}

@end
