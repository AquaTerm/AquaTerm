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

static AQTColor colormap[AQT_COLORMAP_SIZE];

@implementation AQTAdapter
/*" AQTAdapter is a class that provides an interface to the functionality of AquaTerm.
As such, it bridges the gap between client's procedural calls requesting operations
such as drawing a line or placing a label and the object-oriented graph being built.
The actual assembling of the graph is performed by an instance of class AQTPlotBuilder.

It seemlessly provides a connection to the viewer (AquaTerm.app) without any work on behalf of the client.

It also provides some utility functionality such an indexed colormap, and an optional
error handling callback function for the client.
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

/*" Optionally set an event handling routine"*/
- (void)setEventHandler:(void (*)(NSString *event))fPtr
{
  _eventHandler = fPtr;
}

/*" Optionally set an error handling routine to override default behaviour "*/
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr
{
  _errorHandler = fPtr;
}

- (AQTPlotBuilder *)builder
{
  return _selectedBuilder;
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

- (NSString *)fontname
{
  return [_selectedBuilder fontname];
}

- (void)setFontname:(NSString *)newFontname
{
  [_selectedBuilder setFontname:newFontname];
}

- (float)fontsize
{
  return [_selectedBuilder fontsize];
}

- (void)setFontsize:(float)newFontsize
{
  [_selectedBuilder setFontsize:newFontsize];
}

/*" Return the current linewidth (in points)."*/
- (float)linewidth
{
  return [_selectedBuilder linewidth];
}

/*" Set the current linewidth (in points), used for all subsequent lines. Any line currently being built by #moveToPoint:/#addLineToPoint will be considered finished since any coalesced sequence of line segments must share the same linewidth. "*/
- (void)setLinewidth:(float)newLinewidth
{
  [_selectedBuilder setLinewidth:newLinewidth];
}

- (void)setLineCapStyle:(int)capStyle
{
  [_selectedBuilder setLineCapStyle:capStyle];
}


- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle justification:(int)just
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

/*" Add a filled rectangle. Should normally be preceeded with #eraseRect: to remove any objects that will be covered by aRect."*/
- (void)addFilledRect:(NSRect)aRect
{
  [_selectedBuilder addFilledRect:aRect];
}

/*" Remove any objects inside aRect."*/
- (void)eraseRect:(NSRect)aRect
{
  [_selectedBuilder eraseRect:aRect];
}

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

- (void)resetImageTransform
{
  AQTAffineTransformStruct trans;
  trans.m11 = 1.0;
  trans.m22 = 1.0;
  [_selectedBuilder setImageTransform:trans];
}

- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  [_selectedBuilder addImageWithBitmap:bitmap size:bitmapSize bounds:destBounds];
}

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

- (NSString *)lastEvent
{
  return [_selectedBuilder lastEvent];
}

/*" Creates a new builder instance, adds it to the list of builders and makes it the selected builder "*/
- (void)openPlotIndex:(int)refNum 
{
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

/*" Get the builder instance for refNum and make it the selected builder. If no builder exists for refNum, the selected builder remain unchanged. Returns YES on success. "*/
- (BOOL)selectPlot:(int)refNum
{
  AQTPlotBuilder *tmpBuilder = [_builders objectForKey:[NSString stringWithFormat:@"%d", refNum]];
  if(tmpBuilder)
  {
    _selectedBuilder = tmpBuilder;
    return YES;
  }
  return NO;
}

- (void)clearPlot
{
  if (_selectedBuilder)
  {
    [_selectedBuilder eraseRect:NSMakeRect(0,0,1000,1000)]; // FIXME: !!!
    [_selectedBuilder render];
  }
  
}

/*" Removes the selected builder from the list of builders and sets selected builder to nil."*/
- (void)closePlot
// FIXME: The semantics have changed!!! This should CLOSE the window. NOT close the connection
// Maybe change name to avoid confusion with old meaning...
{
#if(1)
   [self render]; // Debugging 
#endif
}

- (void)setPlotSize:(NSSize)canvasSize
{
  [_selectedBuilder setSize:canvasSize];
}

- (void)setPlotTitle:(NSString *)title
{
  [_selectedBuilder setTitle:title?title:@"Untitled"];
}

/*" Hand a copy of the current plot to the viewer "*/
- (void)render 
{
   [_selectedBuilder render];
}
@end

