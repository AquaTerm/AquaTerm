//
//  AQTAdapter.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

// FIXME: Use only C types, and improve method names.
#import <ApplicationServices/ApplicationServices.h>


#import "AQTAdapter.h"
#import "AQTAdapterPrivateMethods.h"
#import "AQTGraphic.h"
#import "AQTImage.h"
#import "AQTPlotBuilder.h"
#import "AQTConnectionProtocol.h"

static AQTColor colormap[AQT_COLORMAP_SIZE];  // FIXME: proper handling

@implementation AQTAdapter
/*" AQTAdapter is a class that provides an interface to the functionality of AquaTerm.
As such, it bridges the gap between client's procedural calls requesting operations
such as drawing a line or placing a label and the object-oriented graph being built.
The actual assembling of the graph is performed by an instance of class AQTPlotBuilder.

It seemlessly provides a connection to the viewer (AquaTerm.app) without any work on behalf of the client.

It also provides some utility functionality such an indexed colormap, and an optional
error handling callback function for the client.

Event handling of user input is provided through an optional callback function.

#Example: HelloAquaTerm.c
!{
#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

   int main(void)
   {
      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
      AQTAdapter *adapter = [[AQTAdapter alloc] init];
      [adapter openPlotWithIndex:1];
      [adapter setPlotSize:NSMakeSize(600,400)];
      [adapter addLabel:@"HelloAquaTerm!" position:NSMakePoint(300, 200) angle:0.0 justification:1];
      [adapter renderPlot];
      [adapter release];
      [pool release];
      return 0;
   }
}

!{gcc -ObjC main.c -o aqtex -I/Users/per/include -L/Users/per/lib -lobjc -laqt -framework Foundation}
!{gcc main.m -o aqtex -I/Users/per/include -L/Users/per/lib -laqt -framework Foundation}
"*/

/*" This is the designated initalizer, allowing for the default handler (an object vended by AquaTerm via OS X's distributed objects mechanism) to be replaced by a local instance. In most cases #init should be used, which calls #initWithHandler: with a nil argument."*/
-(id)initWithServer:(id)localServer
{
   if(self = [super init])
   {
      _builders = [[NSMutableDictionary alloc] initWithCapacity:256];
      if(localServer)
      {
         _server = localServer;
         _serverIsLocal=YES;
      }
      else
      {
         if([self _connectToServer] == NO)
         {
            // FIXME: Check up on this
            [self autorelease];
            self = nil;
         }
      }
   }
   return self;
}

/*" Initializes an instance and sets up a connection to the handler object via DO. Launches AquaTerm if necessary. "*/
- (id)init
{
   return [self initWithServer:nil];
}

- (void)dealloc
{
   NSLog(@"byebye from adapter");
   // Must come before others, see AQTPlotBuilder
   NS_DURING
      NSEnumerator *enumObjects = [_builders objectEnumerator];
      AQTPlotBuilder *aBuilder;
      while (aBuilder = [enumObjects nextObject])
      {
         if ([_server removeAQTClient:aBuilder] == NO)
         {
            NSLog(@"Couldn't remove remote client lock, leaking");
         }
      }
      NS_HANDLER
         NSLog(@"Discarding exception...");
      NS_ENDHANDLER
      [_builders release];
      if(_serverIsLocal == NO)
      {
         [_server release];
      }
      [super dealloc];
}

/*" Inform AquaTerm whether or events should be passed from the currently selected plot. Deactivates event passing from any plot previously set to pass events. "*/
- (void)setAcceptingEvents:(BOOL)flag
{
   NSEnumerator *enumObjects = [_builders objectEnumerator];
   AQTPlotBuilder *aBuilder;
   if (flag == YES)
   {
      // Make sure only one view per client process events
      while (aBuilder = [enumObjects nextObject])
      {
         [aBuilder setAcceptingEvents:NO];
      }
   }
   [_selectedBuilder setAcceptingEvents:flag];
}

/*" Optionally set an event handling routine of the form #customEventHandler(NSString *event).
The structure of the string event is @"type:data1:data2:..."
Currently supported events are:
_{event description}
_{0 NoEvent }
_{1:%{x,y}:%button MouseDownEvent }
_{2:%{x,y}:%key KeyDownEvent } "*/
- (void)setEventHandler:(void (*)(NSString *event))fPtr
{
   _eventHandler = fPtr;
}

/*" Optionally set an error handling routine of the form #customErrorHandler(NSString *errMsg) to override default behaviour. "*/
- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr
{
   _errorHandler = fPtr;
}

/*" Set the current color, used for all subsequent items, using explicit RGB components. "*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b
{
   AQTColor newColor;
   newColor.red = r;
   newColor.green = g;
   newColor.blue = b;
   [_selectedBuilder setColor:newColor];
}

/*" Set the current color, used for all subsequent items, using the color stored at the position given by index in the current colormap. "*/
- (void)takeColorFromColormapEntry:(int)index
{
   if (index < AQT_COLORMAP_SIZE-1 && index >= 0)
   {
      [_selectedBuilder setColor:colormap[index]];
   }
}

/*" Set the background color, overriding any previous color, using explicit RGB components. "*/
- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b
{
   AQTColor newColor;
   newColor.red = r;
   newColor.green = g;
   newColor.blue = b;
   [_selectedBuilder setBackgroundColor:newColor];
}

/*" Set the background color, overriding any previous color, using the color stored at the position given by index in the current colormap. "*/
- (void)takeBackgroundColorFromColormapEntry:(int)index
{
   if (index < AQT_COLORMAP_SIZE-1 && index >= 0)
   {
      [_selectedBuilder setBackgroundColor:colormap[index]];
   }
}

/*" Get current RGB color components by reference. "*/
- (void)getCurrentColorRed:(float *)r green:(float *)g blue:(float *)b
{
   AQTColor tmpColor = [_selectedBuilder color];
   *r = tmpColor.red;
   *g = tmpColor.green;
   *b = tmpColor.blue;
}

/*" Set an RGB entry in the current colormap at the position given by entryIndex. "*/
- (void)setColormapEntry:(int)entryIndex red:(float)r green:(float)g blue:(float)b
{
   if (entryIndex < AQT_COLORMAP_SIZE-1 && entryIndex >= 0)
   {
      colormap[entryIndex].red = r;
      colormap[entryIndex].green = g;
      colormap[entryIndex].blue = b;
   }
}

/*" Set an RGB entry in the current colormap at the position given by entryIndex. "*/
- (void)getColormapEntry:(int)entryIndex red:(float *)r green:(float *)g blue:(float *)b
{
   if (entryIndex < AQT_COLORMAP_SIZE-1 && entryIndex >= 0)
   {
      *r = colormap[entryIndex].red;
      *g = colormap[entryIndex].green;
      *b = colormap[entryIndex].blue;
   }
}

/*" Return the name of the font currently in use. "*/
- (NSString *)fontname
{
   return [_selectedBuilder fontname];
}

/*" Set the font to be used. Applies to all future operations. Default is Times-Roman."*/
- (void)setFontname:(NSString *)newFontname
{
   [_selectedBuilder setFontname:newFontname];
}

/*" Return the size of the font currently in use. "*/
- (float)fontsize
{
   return [_selectedBuilder fontsize];
}

/*" Set the font size in points. Applies to all future operations. Default is 14pt. "*/
- (void)setFontsize:(float)newFontsize
{
   [_selectedBuilder setFontsize:newFontsize];
}

/*" Return the current linewidth (in points)."*/
- (float)linewidth
{
   return [_selectedBuilder linewidth];
}

/*" Set the current linewidth (in points), used for all subsequent lines. Any line currently being built by #moveToPoint:/#addLineToPoint will be considered finished since any coalesced sequence of line segments must share the same linewidth.  Default linewidth is 1pt."*/
- (void)setLinewidth:(float)newLinewidth
{
   [_selectedBuilder setLinewidth:newLinewidth];
}

/*" Set the current line cap style (in points), used for all subsequent lines. Any line currently being built by #moveToPoint:/#addLineToPoint will be considered finished since any coalesced sequence of line segments must share the same cap style.
_{capStyle Description}
_{0 ButtLineCapStyle}
_{1 RoundLineCapStyle}
_{2 SquareLineCapStyle}
Default is RoundLineCapStyle. "*/
- (void)setLineCapStyle:(int)capStyle
{
   [_selectedBuilder setLineCapStyle:capStyle];
}

/*" Add text at coordinate given by pos, rotated by angle degrees and aligned (with respect to pos, along the rotated baseline) according to align.
_{align Description}
_{0 LeftAligned}
_{1 Centered}
_{2 RightAligned}
The text can be either an NSString or an NSAttributedString. By using NSAttributedString a subset of the attributes defined in AppKit may be used to format the string beyond the fontface ans size. The currently supported attributes are
_{Attribute value}
_{@"NSSuperScript" raise-level}
_{@"NSUnderline" 0or1}
"*/
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle align:(int)just
{
   [_selectedBuilder addLabel:text position:pos angle:angle justification:just];
}

/*" Moves the current point (in canvas coordinates) in preparation for a new sequence of line segments. "*/
- (void)moveToPoint:(NSPoint)point
{
   [_selectedBuilder moveToPoint:point];
}

/*" Add a line segment from the current point (given by a previous #moveToPoint: or #addLineToPoint). "*/
- (void)addLineToPoint:(NSPoint)point
{
   [_selectedBuilder addLineToPoint:point];
}

/*" Add a sequence of line segments specified by a list of start-, end-, and joinpoint(s) in points. Parameter pc is number of line segments + 1."*/
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc
{
   [_selectedBuilder addPolylineWithPoints:points pointCount:pc];
}

/*" Add a polygon specified by a list of corner points. Number of corners is passed in pc."*/
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
   [_selectedBuilder addPolygonWithPoints:points pointCount:pc];
}

/*" Add a filled rectangle. Will attempt to remove any objects that will be covered by aRect."*/
- (void)addFilledRect:(NSRect)aRect
{
   [_selectedBuilder addFilledRect:aRect];
}

/*" Remove any objects inside aRect."*/
- (void)eraseRect:(NSRect)aRect
{
   [_selectedBuilder eraseRect:aRect];
}

/*" Set a transformation matrix for images added by #)addTransformedImageWithBitmap:size:clipRect:, see NSImage documentation for details. "*/
- (void)setImageTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 tX:(float)tX tY:(float)tY
{
   AQTAffineTransformStruct trans;
   trans.m11 = m11;
   trans.m12 = m12;
   trans.m21 = m21;
   trans.m22 = m22;
   trans.tX = tX;
   trans.tY = tY;
   [_selectedBuilder setImageTransform:trans];
}

/*" Set transformation matrix to unity, e.g. no transform "*/
- (void)resetImageTransform
{
   AQTAffineTransformStruct trans;
   trans.m11 = 1.0;
   trans.m22 = 1.0;
   [_selectedBuilder setImageTransform:trans];
}

/*" Add a bitmap image of size bitmapSize scaled to fit destBounds, does %not apply transform. Bitmap format is 24bits per pixel in sequnce RGBRGBÉ "*/
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
   [_selectedBuilder addImageWithBitmap:bitmap size:bitmapSize bounds:destBounds];
}

/*" Add a bitmap image of size bitmapSize %honoring transform, transformed image is clipped to destBounds. Bitmap format is 24bits per pixel in sequnce RGBRGBÉ "*/
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds
{
   [_selectedBuilder addTransformedImageWithBitmap:bitmap size:bitmapSize clipRect:destBounds];
}


#pragma mark === Control operations ===
- (void)processEvent:(NSString *)event
{
   if (_eventHandler != nil)
   {
      NSLog(@"Passing to handler");
      _eventHandler(event);
   }
   else
   {
      NSLog(@"No handler");
   }
}

/*" Reads the last event logged by the viewer. Will always return NoEvent unless #setAcceptingEvents: is called with a YES argument."*/
- (NSString *)lastEvent
{
   return [_selectedBuilder lastEvent];
}

/* Creates a new builder instance, adds it to the list of builders and makes it the selected builder. If the referenced builder exists, it is selected and cleared. */
/*" Open up a new plot with internal reference number refNum and make it the target for subsequent commands. If the referenced plot already exists, it is selected and cleared. Disables event handling for previously targeted plot. "*/
- (void)openPlotWithIndex:(int)refNum
{
   [_selectedBuilder setAcceptingEvents:NO]; // FIXME: This may or may not be desirable
   if ([self selectPlotWithIndex:refNum])
   {
      // already exists, just select and reset
      [self clearPlot];
   }
   else
   {
      // create a new builder and request a new handler from the server
      AQTPlotBuilder *newBuilder = [[AQTPlotBuilder alloc] init];
      id newHandler;
      NS_DURING
         newHandler = [_server addAQTClient:newBuilder
                                       name:[[NSProcessInfo processInfo] processName]
                                        pid:[[NSProcessInfo processInfo] processIdentifier]];
      NS_HANDLER
         if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
            [self _serverError];
         else
            [localException raise];
      NS_ENDHANDLER
      if (newHandler)
      {
         [_builders setObject:newBuilder forKey:[NSString stringWithFormat:@"%d", refNum]];
         [newBuilder setHandler:newHandler];
         [newBuilder setOwner:self];
         _selectedBuilder = newBuilder;
      }
      [newBuilder release];
   }
}

/*" Get the plot referenced by refNum and make it the target for subsequent commands. If no plot exists for refNum, the currently targeted plot remain unchanged. Disables event handling for previously targeted plot. Returns YES on success. "*/
- (BOOL)selectPlotWithIndex:(int)refNum
{
   AQTPlotBuilder *tmpBuilder = [_builders objectForKey:[NSString stringWithFormat:@"%d", refNum]];
   if(tmpBuilder)
   {
      [_selectedBuilder setAcceptingEvents:NO]; // FIXME: This may or may not be desirable
      _selectedBuilder = tmpBuilder;
      return YES;
   }
   return NO;
}

/*" Clears the current plot and resets default values. To keep plot settings, use #eraseRect: instead. "*/
- (void)clearPlot
{
   if (_selectedBuilder)
   {
      [_selectedBuilder clearAll];
      [_selectedBuilder render];
   }
}

/*" Closes the current plot but leaves viewer window on screen. Disables event handling. "*/
- (void)closePlot
{
#if(0)
   [self renderPlot]; // Debugging
#else
   if (_selectedBuilder)
   {
      NSArray *keys = [_builders allKeysForObject:_selectedBuilder];
      NS_DURING
         if ([_server removeAQTClient:_selectedBuilder] == NO)
         {
            NSLog(@"Couldn't remove remote client lock, leaking");
         }
      NS_HANDLER
         NSLog(@"Discarding exception...");
      NS_ENDHANDLER
      if ([keys count]>0)
      {
         [_builders removeObjectForKey:[keys objectAtIndex:0]];
      }
      _selectedBuilder = nil; // FIXME: inserting a generic logging object here for debugging??
   }
#endif
}

/*" Set the limits of the plot area. Must be set %before any drawing command following an #openPlotWithIndex: or #clearPlot command or behaviour is undefined.  "*/
- (void)setPlotSize:(NSSize)canvasSize
{
   [_selectedBuilder setSize:canvasSize];
}

/*" Set title to appear in window titlebar, also default name when saving. "*/
- (void)setPlotTitle:(NSString *)title
{
   [_selectedBuilder setTitle:title?title:@"Untitled"];
}

/*" Render the current plot in the viewer. "*/
- (void)renderPlot
{
   [_selectedBuilder render];
}
@end

