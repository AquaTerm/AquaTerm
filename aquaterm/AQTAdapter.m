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
#import "AQTModel.h"
#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTPatch.h"
#import "AQTImage.h"
#import "AQTConnectionProtocol.h"
#import "AQTClientProtocol.h"

@interface AQTAdapter (AQTAdapterPrivateMethods)
- (BOOL)_connectToServer;
- (BOOL)_launchServer;
- (void)_serverError;
@end

@implementation AQTAdapter
-(id)initWithHandler:(id )localHandler // Designated init
{
  if(self = [super init])
  {
    AQTModel *nilModel = [[AQTModel alloc] initWithSize:NSMakeSize(300,200)];
    [self setModel:nilModel];
    [nilModel release];
    _modelIsDirty = NO;
    uniqueId = [[NSString stringWithString:[[NSProcessInfo processInfo] globallyUniqueString]] retain];
    procName = [[NSString stringWithString:[[NSProcessInfo processInfo] processName]] retain];
    procId = [[NSProcessInfo processInfo] globallyUniqueString];
    NSLog(@"procUniqueId: %@\nprocName: %@\nprocId: %d", uniqueId, procName, procId);
    // Default values:

    _color.red = 0.0;
    _color.green = 0.0;
    _color.blue = 0.0;
    _fontname = @"Times-Roman";
    _fontsize = 18.0;
    _linewidth = .2;
    if(localHandler)
    {
      _handler = localHandler;
    }
    else
    {
      // BOOL test = [self _connectToServer];
      if([self _connectToServer])
      {
        NS_DURING
          _handler = [_server addAQTClientWithId:uniqueId name:procName pid:procId];
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

- (id)init
{
  return [self initWithHandler:nil];
}

- (void)dealloc
{
  NSLog(@"byebye from adapter %@", uniqueId);
  NS_DURING
    [_server removeAQTClientWithId:uniqueId]; // Where to place this???
  NS_HANDLER
//    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"] ||Ê[[localException name] isEqualToString:NSObjectInaccessibleException])
      NSLog(@"NOOP");
//    else
//      [localException raise];
  NS_ENDHANDLER
  [_handler release];
  [_server release];
  [uniqueId release];
  [procName release];
  [_model release];
  [super dealloc];
}

- (void)setErrorHandler:(void (*)(NSString *msg))fPtr
{
  _errorHandler = fPtr;
}
- (void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [_model release];
  _model = newModel;
}

- (AQTModel *)model
{
  return _model;
}

- (AQTColor)color {
  return _color;
}

- (void)setColorRed:(float)r green:(float)g blue:(float)b
{
  _color.red = r;
  _color.green = g;
  _color.blue = b;
}

- (void)setColor:(AQTColor)newColor
{
  _color = newColor;
}

- (NSString *)fontname
{
  return _fontname;
}

- (void)setFontname:(NSString *)newFontname
{
  if (_fontname != newFontname)
  {
    NSString *oldValue = _fontname;
    _fontname = [newFontname retain];
    [oldValue release];
  }
}

- (float)fontsize
{
  return _fontsize;
}

- (void)setFontsize:(float)newFontsize
{
  _fontsize = newFontsize;
}

- (float)linewidth
{
  return _linewidth;
}

- (void)setLinewidth:(float)newLinewidth
{
  _linewidth = newLinewidth;
}
- (void)eraseRect:(NSRect)aRect
{
  [[self model] removeObjectsInRect:aRect];
}

//
// AQTLabel
//
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just
{
  AQTLabel *lb = [[AQTLabel alloc] initWithAttributedString:[[[NSAttributedString  alloc] initWithString:text] autorelease]
                                                   position:pos
                                                      angle:angle
                                              justification:just];
  [[self model] addObject:lb];
  [lb release];
  _modelIsDirty = YES;
}
//
// AQTPath
//
- (void)addLineAtPoint:(NSPoint)point
{
  if (_pointCount > 1)
  {
    AQTPath *tmpPath = [[AQTPath alloc] initWithPoints:_path pointCount:_pointCount color:_color];
    [tmpPath setLinewidth:_linewidth];
    [[self model] addObject:tmpPath];
    [tmpPath release];
  }
  _path[0]=point;
  _pointCount = 1;
  _modelIsDirty = YES;
}

- (void)appendLineToPoint:(NSPoint)point
{
  _path[_pointCount]=point;
  _pointCount++;
  if (_pointCount == MAX_PATH_POINTS)
  {
    [self addLineAtPoint:point];
  }
  _modelIsDirty = YES;
}
//
// AQTPatch
//
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
  AQTPatch *tmpPatch;
  if (pc > MAX_PATH_POINTS)
    NSLog(@"Path too long (%d)", pc);	// FIXME: take action here!
  tmpPatch = [[AQTPatch alloc] initWithPoints:points pointCount:pc color:_color];
  [[self model] addObject:tmpPatch];
  [tmpPatch release];
  _modelIsDirty = YES;

}
//
// AQTImage
//
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
  [[self model] addObject:tmpImage];
  [tmpImage release];
  _modelIsDirty = YES;

}
//
// Control operations
//
- (void)openPlotIndex:(int)refNum size:(NSSize)canvasSize title:(NSString *)title // if title param is nil, title defaults to Figure <n>
{
  AQTModel *newModel = [[AQTModel alloc] initWithSize:canvasSize];
  [self setModel:newModel];
  [newModel release];
  _modelRefNumber = refNum;
  _modelIsDirty = NO;
  if (title)
  {
    [[self model] setTitle:title];
  }
  else
  {
    [[self model] setTitle:[NSString stringWithFormat:@"Figure %d", refNum]];
    NSLog(@"Using default title");
  }
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
  if (_modelIsDirty)
  {
    NS_DURING
      [_handler setModel:_model];	// the renderer will retain this object
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
    _modelIsDirty = NO;
  }
}
- (void)render //(push [partial] model to renderer)
{
  // FIXME: if model hasn't changed, don't update!!!
  NS_DURING
    if (_modelIsDirty)
    {
      [_handler setModel:_model];	// the renderer will retain this object
      _modelIsDirty = NO;
    }
    else
    {
      [_handler setModel:_model];	// the renderer will retain this object
      NSLog(@"*** Error -- trying to render non-dirty model ***");
    }
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self _serverError];
      else
        [localException raise];
    NS_ENDHANDLER
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
        _handler = [_server addAQTClientWithId:uniqueId name:procName pid:procId];
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
