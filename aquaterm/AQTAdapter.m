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
#import "AQTPlotBuilder.h"
/*
#import "AQTGraphic.h"
#import "AQTModel.h"
#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTPatch.h"
#import "AQTImage.h"
*/
#import "AQTConnectionProtocol.h"
#import "AQTClientProtocol.h"

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

/*" This is the designated initalizer, allowing for the default handler (an object vended by AquaTerm via OS X's distributed objects mechanism) to be replaced by a local instance. In most cases #init should be used, which calls #{initWithHandler:} with a nil argument."*/
-(id)initWithHandler:(id)localHandler 
{
  if(self = [super init])
  {
    [self setBuilder:[[AQTPlotBuilder alloc] init]];
    _uniqueId = [[NSString stringWithString:[[NSProcessInfo processInfo] globallyUniqueString]] retain];
    _procName = [[NSString stringWithString:[[NSProcessInfo processInfo] processName]] retain];
    _procId = [[NSProcessInfo processInfo] processIdentifier];
    NSLog(@"procUniqueId: %@\nprocName: %@\nprocId: %d", _uniqueId, _procName, _procId);
    if(localHandler)
    {
      _handler = localHandler;
    }
    else
    {
      if([self _connectToServer])
      {
        NS_DURING
          _handler = [_server addAQTClientWithId:_uniqueId name:_procName pid:_procId];
          [_handler retain];
          [_handler setProtocolForProxy:@protocol(AQTClientProtocol)];
        NS_HANDLER
          if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
            [self _serverError];
          else
            [localException raise];
        NS_ENDHANDLER
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
  return [self initWithHandler:nil];
}

- (void)dealloc
{
  NSLog(@"byebye from adapter %@", _uniqueId);
  NS_DURING
    [_server removeAQTClientWithId:_uniqueId]; // Where to place this???
  NS_HANDLER
      NSLog(@"Discarding exception...");
  NS_ENDHANDLER
  [_handler release];
  [_server release];
  [_uniqueId release];
  [_procName release];
  [_builder release];
  [super dealloc];
}

/*" Optionally set an error handling routine to override default behaviour "*/
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr
{
  _errorHandler = fPtr;
}

- (void)setBuilder:(AQTPlotBuilder *)newBuilder
{
  [newBuilder retain];
  [_builder release];
  _builder=newBuilder;
}
- (AQTPlotBuilder *)builder
{
  return _builder;
}

/*
 - (AQTColor)color {
  return _color;
}
*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b
{
  [_builder setColorRed:r green:g blue:b];
}
/*
- (void)setColor:(AQTColor)newColor
{
  _color = newColor;
}
*/

// FIXME: key-value coding for accessors?
- (NSString *)fontname
{
  return [_builder fontname];
}

- (void)setFontname:(NSString *)newFontname
{
  [_builder setFontname:newFontname];
}

- (float)fontsize
{
  return [_builder fontsize];
}

- (void)setFontsize:(float)newFontsize
{
  [_builder setFontsize:newFontsize];
}

- (float)linewidth
{
  return [_builder linewidth];
}

- (void)setLinewidth:(float)newLinewidth
{
  [_builder setLinewidth:newLinewidth];
}
- (void)eraseRect:(NSRect)aRect
{
  [_builder eraseRect:aRect];
}

- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just
{
  [_builder addLabel:text position:pos angle:angle justification:just];
}

- (void)addLineAtPoint:(NSPoint)point
{
  [_builder addLineAtPoint:point];
}

- (void)appendLineToPoint:(NSPoint)point
{
  [_builder appendLineToPoint:point];
}

- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
  [_builder addPolygonWithPoints:points pointCount:pc];
}

- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  [_builder addImageWithBitmap:bitmap size:bitmapSize bounds:destBounds];
}
//
// Control operations
//
- (void)openPlotIndex:(int)refNum size:(NSSize)canvasSize title:(NSString *)title // if title param is nil, title defaults to Figure <n>
{
  [self setBuilder:[[AQTPlotBuilder alloc] init]];
  [_builder setSize:canvasSize];
  [_builder setTitle:title?title:[NSString stringWithFormat:@"Figure %d", refNum]];
  NS_DURING
    [_handler selectView:refNum];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self _serverError];
    else
      [localException raise];
  NS_ENDHANDLER

}
- (void)closePlot
{
  // FIXME: Check if model is dirty and that buffers are flushed,
  // don't set model unless necessary -- just release the local
  if ([_builder modelIsDirty])
  {
    NS_DURING
      [_handler setModel:[_builder model]];	// the renderer will retain this object
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
  //  _modelIsDirty = NO;
  }
}
- (void)render //(push [partial] model to renderer)
{
  // FIXME: if model hasn't changed, don't update!!!
    if ([_builder modelIsDirty])
    {
  NS_DURING
      [_handler setModel:[_builder model]];	// the renderer will retain this object
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
      //_modelIsDirty = NO;
    }
    else
    {
      //[_handler setModel:_model];	// the renderer will retain this object
      NSLog(@"*** Error -- trying to render non-dirty model ***");
    }
}
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options
{
  char keyPressed;
  NS_DURING
    [_handler beginMouse];
    do
    {
      // Sleep this thread for .1 s at a time. FIXME: Will not work if non-DO client
      [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (![_handler mouseIsDone]);
    keyPressed = [_handler mouseDownInfo:mouseLoc];
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
        _handler = [_server addAQTClientWithId:_uniqueId name:_procName pid:_procId];
        [_handler retain];
        [_handler setProtocolForProxy:@protocol(AQTClientProtocol)];
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
