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
#import "AQTGraphic.h"
#import "AQTImage.h"
#import "AQTPlotBuilder.h"
#import "AQTConnectionProtocol.h"
#import "AQTClientProtocol.h"

static AQTColor colormap[AQT_COLORMAP_SIZE];

@interface AQTAdapter (AQTAdapterPrivateMethods)
- (BOOL)_connectToServer;
- (BOOL)_launchServer;
- (void)_serverError;
@end

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
    //[self setBuilder:[[AQTPlotBuilder alloc] init]];
    _builders = [[NSMutableDictionary alloc] initWithCapacity:256];
    _handlers = [[NSMutableDictionary alloc] initWithCapacity:256];
    _uniqueId = [[NSString stringWithString:[[NSProcessInfo processInfo] globallyUniqueString]] retain];
    _procName = [[NSString stringWithString:[[NSProcessInfo processInfo] processName]] retain];
    _procId = [[NSProcessInfo processInfo] processIdentifier];
    NSLog(@"procUniqueId: %@\nprocName: %@\nprocId: %d", _uniqueId, _procName, _procId);
    if(localServer)
    {
      _server = localServer;
    }
    else
    {
      if([self _connectToServer])
      {
/*
 NS_DURING
          _selectedHandler = [_server addAQTClientWithId:_uniqueId name:_procName pid:_procId];
          [_selectedHandler retain];
          [_selectedHandler setProtocolForProxy:@protocol(AQTClientProtocol)];
        NS_HANDLER
          if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
            [self _serverError];
          else
            [localException raise];
        NS_ENDHANDLER
*/
      }
      else
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
  NSLog(@"byebye from adapter %@", _uniqueId);
  NS_DURING
    [_server removeAQTClientWithId:_uniqueId]; // Where to place this???
  NS_HANDLER
    NSLog(@"Discarding exception...");
  NS_ENDHANDLER
  [_server release];
  [_uniqueId release];
  [_procName release];
  [_builders release];
  [_handlers release];
  [super dealloc];
}

/*" Optionally set an error handling routine to override default behaviour "*/
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr
{
  _errorHandler = fPtr;
}
/*
- (void)setBuilder:(AQTPlotBuilder *)newBuilder
{
  [newBuilder retain];
  [_selectedBuilder release];
  _selectedBuilder=newBuilder;
}
*/
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
//  trans.m12 = m12;
//  trans.m21 = m21;
  trans.m22 = 1.0;
//  trans.tX = tX;
//  trans.tY = tY;
  [_selectedBuilder setImageTransform:trans];
}

- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  [_selectedBuilder addImageWithBitmap:bitmap size:bitmapSize bounds:destBounds];
}

#pragma mark === Control operations ===
/*" Creates a new builder instance, adds it to the list of builders and makes it the selected builder "*/
- (void)openPlotIndex:(int)refNum // size:(NSSize)canvasSize title:(NSString *)title // if title param is nil, title defaults to Figure <n>
{
  id newHandler;
  AQTPlotBuilder *newBuilder;
  NS_DURING
    //[_selectedHandler selectView:refNum];
    newHandler = [_server addAQTClientWithId:_uniqueId name:_procName pid:_procId];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self _serverError];
    else
      [localException raise];
  NS_ENDHANDLER
  if (newHandler)
  {
    [_handlers setObject:newHandler forKey:[NSString stringWithFormat:@"%d", refNum]];
     //    [newHandler setProtocolForProxy:@protocol(AQTClientProtocol)]; // FIXME: test if local client
    _selectedHandler = newHandler;

    newBuilder = [[AQTPlotBuilder alloc] init];
    [_builders setObject:newBuilder forKey:[NSString stringWithFormat:@"%d", refNum]];
    _selectedBuilder = newBuilder;
    [newBuilder release];
//    [_selectedBuilder setSize:canvasSize];
//    [_selectedBuilder setTitle:title?title:[NSString stringWithFormat:@"Figure %d", refNum]];
  }
}

/*" Get the builder instance for refNum and make it the selected builder. If no builder exists for refNum, the selected builder remain unchanged. Returns YES on success. "*/
- (BOOL)selectPlot:(int)refNum
{
  NSString *key = [NSString stringWithFormat:@"%d", refNum];
  AQTPlotBuilder *tmpBuilder = [_builders objectForKey:key];
  id tmpHandler = [_handlers objectForKey:key];
  if(tmpBuilder && tmpHandler)
  {
    _selectedBuilder = tmpBuilder;
    _selectedHandler = tmpHandler;
/*
 NS_DURING
      [_selectedHandler selectView:refNum];
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
*/
    return YES;
  }
  return NO;
}

- (void)clearPlot
{
  if (_selectedBuilder)
  {
    [_selectedBuilder eraseRect:NSMakeRect(0,0,1000,1000)]; // FIXME: !!!
    [self render];
  }
  
}

/*" Removes the selected builder from the list of builders and sets selected builder to nil."*/
- (void)closePlot
{
  NSEnumerator *enumKeys = [_builders keyEnumerator];
  NSString *aKey;
  // FIXME: Check if model is dirty and that buffers are flushed,
  // don't set model unless necessary -- just release the local
  if (_selectedBuilder && [_selectedBuilder modelIsDirty])
  {
    NS_DURING
      [_selectedHandler setModel:[_selectedBuilder model]];
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
  }
  // remove this builder & handler
  while (aKey = [enumKeys nextObject])
  {
    if ([_builders objectForKey:aKey] == _selectedBuilder)
    {
      [_builders removeObjectForKey:aKey];
      [_handlers removeObjectForKey:aKey];
      break; // Found it.
    }
  }
  _selectedBuilder = nil;
  _selectedHandler = nil;
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
- (void)render //(push [partial] model to renderer)
{
  // FIXME: if model hasn't changed, don't update!!!
  if (_selectedBuilder && [_selectedBuilder modelIsDirty])
  {
    NS_DURING
      [_selectedHandler setModel:[_selectedBuilder model]];
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
  }
  else
  {
    [_selectedHandler setModel:[_selectedBuilder model]];
    NSLog(@"*** Warning -- Rendering non-dirty model ***");
  }
}
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options
{
  char keyPressed;
  if([_selectedBuilder modelIsDirty])
  {
    [self render];
  }
  NS_DURING
    [_selectedHandler beginMouse];
    do
    {
      // Sleep this thread for .1 s at a time. FIXME: Will not work if non-DO client
      [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (![_selectedHandler mouseIsDone]);
    keyPressed = [_selectedHandler mouseDownInfo:mouseLoc];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self _serverError];
    else
      [localException raise];
  NS_ENDHANDLER
  return keyPressed;
}
@end

@implementation AQTAdapter (AQTAdapterPrivateMethods)
- (BOOL)_connectToServer
{

  BOOL didConnect = NO;
  _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
  if (!_server)
    /*
     {
       [_server retain];
       [_server setProtocolForProxy:@protocol(AQTConnectionProtocol)];
       didConnect = YES;
     }
     else
     */
  {
    NSLog(@"Launching server...");
    if (![self _launchServer])
    {
      NSLog(@"Launching failed.");
    }
    else
    {
      // Wait for server to start up
      int timer = 10;
      while (--timer && !didConnect)
      {
        // sleep 1s
        NSLog(@"Waiting...");
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        // check for server connection
        _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
      }
    }
  }
  NS_DURING
    if (_server)
    {
      if ([_server conformsToProtocol:@protocol(AQTConnectionProtocol)])
      {
        NSLog(@"Conforming!");
        [_server retain];
        [_server setProtocolForProxy:@protocol(AQTConnectionProtocol)];
        didConnect = YES;
      }
      else
      {
        NSLog(@"server is too old info");
        _server = nil;
      }
    }
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
    NSLog(didConnect?@"Connected!":@"Not connected");
    return didConnect;
}

// This is still troublesome... Needs to figure out if user is running from remote machine. NSTask
- (BOOL)_launchServer
{
  NSURL *appURL;

  if (getenv("AQUATERM_PATH") == (char *)NULL)
  { // No, search for it in standard locations
    NSURL *tmpURL;
    appURL = (LSFindApplicationForInfo(NULL, NULL, (CFStringRef)@"AquaTerm.app", NULL, (CFURLRef *)&tmpURL) == noErr)?tmpURL:nil;
  }
  else
  {
    appURL = [NSURL fileURLWithPath:[NSString stringWithCString:getenv("AQUATERM_PATH")]];
    // Setting error msg if anything goes wrong
  }
  return (LSOpenCFURLRef((CFURLRef)appURL, NULL) == noErr);
}

- (void)_serverError
{
  // NSLog(@"Caugth an error!");
  if (_errorHandler)
  {
    _errorHandler(@"Server unavailable --- passing on.");
  }
  else
  {
    NSLog(@"Server error, no handler installed\nTrying to reconnect");
    if([self _connectToServer])
    {
      NS_DURING
        _selectedHandler = [_server addAQTClientWithId:_uniqueId name:_procName pid:_procId];
        [_selectedHandler retain];
        [_selectedHandler setProtocolForProxy:@protocol(AQTClientProtocol)];
      NS_HANDLER
        if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
          [self _serverError];
        else
          [localException raise];
      NS_ENDHANDLER
    }
  }
}
@end
