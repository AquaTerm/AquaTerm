//
//  AQTAdapter.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>

#import "AQTAdapter.h"
#import "AQTAdapterPrivateMethods.h"
#import "AQTGraphic.h"
#import "AQTImage.h"
#import "AQTPlotBuilder.h"
#import "AQTConnectionProtocol.h"

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

- (void)_aqtNoSelectedBuilder
{
   NSLog(@"Error: no valid plot selected.");
}

- (NSNumber *)_aqtKeyForBuilder:(AQTPlotBuilder *)aBuilder
{
   if (aBuilder != nil)
   {
      NSArray *keys = [_builders allKeysForObject:aBuilder];
      if ([keys count] > 0)
      {
         return [keys objectAtIndex:0];
      }
   }
   return nil;
}


/*" This is the designated initalizer, allowing for the default handler (an object vended by AquaTerm via OS X's distributed objects mechanism) to be replaced by a local instance. In most cases #init should be used, which calls #initWithHandler: with a nil argument."*/
-(id)initWithServer:(id)localServer
{
   if(self = [super init])
   {
      _builders = [[NSMutableDictionary alloc] initWithCapacity:256];
      _eventBuffer = [[NSMutableDictionary alloc] initWithCapacity:256];
      if(localServer)
      {
         _server = localServer;
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
      [_eventBuffer release];
      if([_server isProxy])
      {
         [_server release];
      }
      [super dealloc];
}

/*" Inform AquaTerm whether or events should be passed from the currently selected plot. Deactivates event passing from any plot previously set to pass events. "*/
- (void)setAcceptingEvents:(BOOL)flag
{
   // Flush event buffer for the selected view
   [_eventBuffer setObject:@"0" forKey:[self _aqtKeyForBuilder:_selectedBuilder]];
   [_selectedBuilder setAcceptingEvents:flag];
}

/*" Optionally set an event handling routine of the form #customEventHandler(int index, NSString *event).
The reference number of the plot that generated the event is passed in index and
the structure of the string event is @"type:data1:data2:..."
Currently supported events are:
_{event description}
_{0 NoEvent }
_{1:%{x,y}:%button MouseDownEvent }
_{2:%{x,y}:%key KeyDownEvent } "*/
- (void)setEventHandler:(void (*)(int index, NSString *event))fPtr
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

/*" Set the current color, used for all subsequent items, using the color stored at the position given by index in the colormap. "*/
- (void)takeColorFromColormapEntry:(int)index
{
   [_selectedBuilder takeColorFromColormapEntry:index];
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

/*" Set the background color, overriding any previous color, using the color stored at the position given by index in the colormap. "*/
- (void)takeBackgroundColorFromColormapEntry:(int)index
{
   [_selectedBuilder takeBackgroundColorFromColormapEntry:index];
}

/*" Get current RGB color components by reference. "*/
- (void)getCurrentColorRed:(float *)r green:(float *)g blue:(float *)b
{
   AQTColor tmpColor = [_selectedBuilder color];
   *r = tmpColor.red;
   *g = tmpColor.green;
   *b = tmpColor.blue;
}

/*" Return the number of color entries availabel in the currently active colormap. "*/
- (int)colormapSize
{
   if (_selectedBuilder)
   {
      return [_selectedBuilder colormapSize];
   }
   [self _aqtNoSelectedBuilder];
   return 0;
}

/*" Set an RGB entry in the colormap, at the position given by entryIndex. "*/
- (void)setColormapEntry:(int)entryIndex red:(float)r green:(float)g blue:(float)b
{
   AQTColor tmpColor;
   tmpColor.red = r;
   tmpColor.green = g;
   tmpColor.blue = b;
   [_selectedBuilder setColor:tmpColor forColormapEntry:entryIndex];
}

/*" Set an RGB entry in the colormap, at the position given by entryIndex. "*/
- (void)getColormapEntry:(int)entryIndex red:(float *)r green:(float *)g blue:(float *)b
{
   AQTColor tmpColor = [_selectedBuilder colorForColormapEntry:entryIndex];
   *r = tmpColor.red;
   *g = tmpColor.green;
   *b = tmpColor.blue;
}

/*" Set the font to be used. Applies to all future operations. Default is Times-Roman."*/
- (void)setFontname:(NSString *)newFontname
{
   [_selectedBuilder setFontname:newFontname];
}

/*" Set the font size in points. Applies to all future operations. Default is 14pt. "*/
- (void)setFontsize:(float)newFontsize
{
   [_selectedBuilder setFontsize:newFontsize];
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

/*" Add a sequence of line segments specified by a list of start-, end-, and joincoordinate(s) in x and y. Parameter pc is number of line segments + 1."*/
- (void)addPolylineWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc
{
   [_selectedBuilder addPolylineWithXCoords:x yCoords:y pointCount:pc];
}

/*" Add a polygon specified by a list of corner points. Number of corners is passed in pc."*/
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
   [_selectedBuilder addPolygonWithPoints:points pointCount:pc];
}

/*" Add a polygon specified by a list of corner coordinates in x and y. Number of corners is passed in pc."*/
- (void)addPolygonWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc
{
   [_selectedBuilder addPolygonWithXCoords:x yCoords:y pointCount:pc];   
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
- (void)processEvent:(NSString *)event sender:(id)sender // FIXME: Make private
{

   NSNumber *key = [self _aqtKeyForBuilder:sender];
   if (_eventHandler != nil)
   {
      _eventHandler([key intValue], event);
   }
   [_eventBuffer setObject:event forKey:key];
}

/*" Reads the last event logged by the viewer. Will always return NoEvent unless #setAcceptingEvents: is called with a YES argument."*/
- (NSString *)lastEvent
{
   NSString *event;
   NSNumber *key = [self _aqtKeyForBuilder:_selectedBuilder];
   event = [[[_eventBuffer objectForKey:key] copy] autorelease];
   [_eventBuffer setObject:@"0" forKey:key];
   return event;
}

- (NSString *)waitNextEvent // FIXME: timeout? Hardcoded to 60s
{
   NSString *event;
   BOOL isRunning;
   [_selectedBuilder setAcceptingEvents:YES];
   do {
      isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:60.0]];
      event = [self lastEvent];
      if (![event isEqualToString:@"0"])
      {
         isRunning = NO;
      }
   } while (isRunning);
   [_selectedBuilder setAcceptingEvents:NO];
   return event;
}

/* Creates a new builder instance, adds it to the list of builders and makes it the selected builder. If the referenced builder exists, it is selected and cleared. */
/*" Open up a new plot with internal reference number refNum and make it the target for subsequent commands. If the referenced plot already exists, it is selected and cleared. Disables event handling for previously targeted plot. "*/
- (void)openPlotWithIndex:(int)refNum
{
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
         if ([[localException name] isEqualToString:NSInvalidSendPortException])
            [self _serverError:[localException name]];
         else
            [localException raise];
      NS_ENDHANDLER
      if (newHandler)
      {
         [_builders setObject:newBuilder forKey:[NSNumber numberWithInt:refNum]];
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
   AQTPlotBuilder *tmpBuilder = [_builders objectForKey:[NSNumber numberWithInt:refNum]];
   if(tmpBuilder)
   {
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
   if (_selectedBuilder)
   {
      NS_DURING
         if ([_server removeAQTClient:_selectedBuilder] == NO)
         {
            NSLog(@"Couldn't remove remote client lock, leaking");
         }
      NS_HANDLER
         NSLog(@"Discarding exception...");
      NS_ENDHANDLER
      [_builders removeObjectForKey:[self _aqtKeyForBuilder:_selectedBuilder]];
      _selectedBuilder = nil; 
   }
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
   if(_selectedBuilder)
   {
      [_selectedBuilder render];
   }
   else
   {
      [self _aqtNoSelectedBuilder];
   }
}
@end

