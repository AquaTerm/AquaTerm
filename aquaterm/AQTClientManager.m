//
//  AQTClientManager.m
//  AquaTerm
//
//  Created by Per Persson on Wed Nov 19 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTClientManager.h"
#import "AQTModel.h"
#import "AQTPlotBuilder.h"

#import "AQTEventProtocol.h"
#import "AQTConnectionProtocol.h"

@implementation AQTClientManager
#pragma mark ==== Error handling ====
- (void)_aqtHandlerError:(NSString *)msg
{
   // FIXME: stuff @"42:Server error" in all event buffers/handlers ?
   [self logMessage:[NSString stringWithFormat:@"Handler error: %@", msg] logLevel:1];
   errorState = YES;
}

- (void)clearErrorState
{
   BOOL serverDidDie = NO;
   NS_DURING
      [_server ping];
   NS_HANDLER
      [self logMessage:@"Server not responding." logLevel:1];
      serverDidDie = YES;
   NS_ENDHANDLER

   if (serverDidDie) {
      [self terminateConnection];
   } else {
      [self closePlot];
   }
   errorState = NO;
}

#pragma mark ==== Init routines ====
+ (AQTClientManager *)sharedManager
{
   static AQTClientManager *sharedManager = nil;
   if (sharedManager == nil) {
      sharedManager = [[self alloc] init];
   }
   return sharedManager;
}

- (id)init
{
   if(self = [super init]) {
      char *envPtr;
      _builders = [[NSMutableDictionary alloc] initWithCapacity:256];
      _plots = [[NSMutableDictionary alloc] initWithCapacity:256];
      _eventBuffer = [[NSMutableDictionary alloc] initWithCapacity:256];
      _logLimit = 0;
      // Read environment variable(s)
      envPtr = getenv("AQUATERM_LOGLEVEL");
      if (envPtr != (char *)NULL) {
         _logLimit = (int)strtol(envPtr, (char **)NULL, 10);
      }
      [self logMessage:[NSString stringWithFormat:@"Warning: Logging at level %d", _logLimit] logLevel:1];
   }
   return self;
}

- (void)dealloc
{
   [NSException raise:@"AQTException" format:@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__];
   [_activePlotKey release];
   [_eventBuffer release];
   [_builders release];
   [_plots release];
   [super dealloc];
}

#pragma mark ==== Server methods ====
- (void)setServer:(id)server
{
   _server = server;
}

- (BOOL)connectToServer
{
   // FIXME: Check to see if _server exists.
   BOOL didConnect = NO;
   _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
   if (!_server) {
      [self logMessage:@"Launching server..." logLevel:2];
      if (![self launchServer]) {
         [self logMessage:@"Launching failed." logLevel:2];
      } else {
         // Wait for server to start up
         int timer = 10;
         while (--timer && !_server) {
            // sleep 1s
            [self logMessage:[NSString stringWithFormat:@"Waiting... %d", timer] logLevel:2];
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            // check for server connection
            _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
         }
      }
   }
   NS_DURING
      if (_server) {
         if ([_server conformsToProtocol:@protocol(AQTConnectionProtocol)]) {
            int a,b,c;
            [_server retain];
            [_server setProtocolForProxy:@protocol(AQTConnectionProtocol)];
            [_server getServerVersionMajor:&a minor:&b rev:&c];
            [self logMessage:[NSString stringWithFormat:@"Server version %d.%d.%d", a, b, c] logLevel:2];
            didConnect = YES;
         } else {
            [self logMessage:@"server is too old info" logLevel:1];
            _server = nil;
         }
      }
      NS_HANDLER
         [localException raise];
      NS_ENDHANDLER
      [self logMessage:didConnect?@"Connected!":@"Could not connect" logLevel:1];
      return didConnect;
}

// This is still troublesome... Needs to figure out if user is running from remote machine. NSTask
- (BOOL)launchServer
{
   NSURL *appURL;

   if (getenv("AQUATERM_PATH") == (char *)NULL) {
      // No, search for it in standard locations
      NSURL *tmpURL;
      appURL = (LSFindApplicationForInfo(NULL, NULL, (CFStringRef)@"AquaTerm.app", NULL, (CFURLRef *)&tmpURL) == noErr)?tmpURL:nil;
   } else {
      appURL = [NSURL fileURLWithPath:[NSString stringWithCString:getenv("AQUATERM_PATH")]];
   }
   return (LSOpenCFURLRef((CFURLRef)appURL, NULL) == noErr);
}

- (void)terminateConnection
{
   NSEnumerator *enumObjects = [_plots keyEnumerator];
   id key;

   while (key = [enumObjects nextObject]) {
      [self setActivePlotKey:key];
      [self closePlot];
   }
   if([_server isProxy]) {
      [_server release];
      _server = nil;
   }
}

#pragma mark ==== Accessors ====

- (void)setActivePlotKey:(id)newActivePlotKey
{
   [newActivePlotKey retain];
   [_activePlotKey release];
   _activePlotKey = newActivePlotKey;
   [self logMessage:_activePlotKey?[NSString stringWithFormat:@"Active plot: %d", [_activePlotKey intValue]]:@"**** plot invalid ****"
           logLevel:3];
}

- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr
{
   _errorHandler = fPtr;
}

- (void)setEventHandler:(void (*)(int index, NSString *event))fPtr
{
   _eventHandler = fPtr;
}

- (void)logMessage:(NSString *)msg logLevel:(int)level
{
   // _logLimit: 0 -- output off
   //            1 -- severe errors
   //            2 -- user debug
   //            3 -- noisy, dev. debug
   if (level > 0 && level <= _logLimit) {
      NSLog(msg);
   }
}

#pragma mark === Plot/builder methods ===

- (AQTPlotBuilder *)newPlotWithIndex:(int)refNum
{
   AQTPlotBuilder *newBuilder;
   NSNumber *key = [NSNumber numberWithInt:refNum];;
   id <AQTClientProtocol> newPlot;

   if (errorState == YES) {
      [self clearErrorState];
      if (_server == nil) {
         [self connectToServer];
      }
   }
   // Check if plot already exists. If so, just select and clear it.
   if ([self selectPlotWithIndex:refNum] != nil) {
      newBuilder = [self clearPlot];
      [_eventBuffer setObject:@"0" forKey:key];
      return newBuilder;
   }   

   NS_DURING
      newPlot = [_server addAQTClient:key
                                 name:[[NSProcessInfo processInfo] processName]
                                  pid:[[NSProcessInfo processInfo] processIdentifier]];
   NS_HANDLER
      [localException raise];
   NS_ENDHANDLER
   if (newPlot) {
      [newPlot setClient:self];
      // set active plot
      [self setActivePlotKey:key];
      [_plots setObject:newPlot forKey:key];
      // Also create a corresponding builder
      newBuilder = [[AQTPlotBuilder alloc] init];
      [_builders setObject:newBuilder forKey:key];
      // Clear event buffer
      [_eventBuffer setObject:@"0" forKey:key];
      [newBuilder release];
   }
   return newBuilder;
}

- (AQTPlotBuilder *)selectPlotWithIndex:(int)refNum
{
   NSNumber *key;
   AQTPlotBuilder *aBuilder;
 
   if (errorState == YES) return nil; // FIXME: Clear error state here too???

   key = [NSNumber numberWithInt:refNum];
   aBuilder = [_builders objectForKey:key];

   if(aBuilder != nil) {
      [self setActivePlotKey:key];
   }
   return aBuilder;
}

- (void)renderPlot 
{
   AQTPlotBuilder *pb;

   if (errorState == YES || _activePlotKey == nil) return;

   pb = [_builders objectForKey:_activePlotKey];
   if ([pb modelIsDirty]) {
      id <NSObject, AQTClientProtocol> thePlot = [_plots objectForKey:_activePlotKey];
      NS_DURING
         if ([thePlot isProxy]) {
            [thePlot appendModel:[pb model]];
            [pb removeAllParts];
         } else {
            [thePlot setModel:[pb model]];
         }
         [thePlot draw];
      NS_HANDLER
         [localException raise];
      NS_ENDHANDLER
   }
}

- (AQTPlotBuilder *)clearPlot
{
   AQTPlotBuilder *newBuilder, *oldBuilder;
   id <NSObject, AQTClientProtocol> thePlot;
   
   if (errorState == YES || _activePlotKey == nil) return nil;

   newBuilder = [[AQTPlotBuilder alloc] init];
   oldBuilder = [_builders objectForKey:_activePlotKey];
   thePlot = [_plots objectForKey:_activePlotKey];
  
   [newBuilder setSize:[[oldBuilder model] canvasSize]];
   [newBuilder setTitle:[[oldBuilder model] title]];
   [newBuilder setBackgroundColor:[oldBuilder backgroundColor]];
   
   [_builders setObject:newBuilder forKey:_activePlotKey];
   NS_DURING
      [thePlot setModel:[newBuilder model]];
      [thePlot draw];
   NS_HANDLER
      [localException raise];
   NS_ENDHANDLER
   [newBuilder release];
   return newBuilder;
}

- (void)clearPlotRect:(NSRect)aRect 
{
   AQTPlotBuilder *pb;
   id <NSObject, AQTClientProtocol> thePlot;

   if (errorState == YES || _activePlotKey == nil) return;

   pb = [_builders objectForKey:_activePlotKey];
   thePlot = [_plots objectForKey:_activePlotKey];

   NS_DURING
      if ([pb modelIsDirty]) {
         if ([thePlot isProxy]) {
            [thePlot appendModel:[pb model]]; // Push any pending output to the viewer, don't draw
            [pb removeAllParts];
         } else {
            [thePlot setModel:[pb model]];
         }
            
      }
      // FIXME make sure in server that this combo doesn't draw unnecessarily
      [thePlot removeGraphicsInRect:aRect];
      // [thePlot draw];
   NS_HANDLER
      [localException raise];
   NS_ENDHANDLER
}

- (void)closePlot
{
   if (_activePlotKey == nil) return;

   NS_DURING
      [[_plots objectForKey:_activePlotKey] setClient:nil];
   NS_HANDLER
      [self logMessage:@"Discarding exception..." logLevel:1];
   NS_ENDHANDLER
   [_plots removeObjectForKey:_activePlotKey];
   [_builders removeObjectForKey:_activePlotKey];
   [self setActivePlotKey:nil];
}

#pragma mark ==== Events ====

- (void)setAcceptingEvents:(BOOL)flag  
{
   if (errorState == YES || _activePlotKey == nil) return;
   [[_plots objectForKey:_activePlotKey] setAcceptingEvents:flag];
}

- (NSString *)lastEvent  
{
   NSString *event;

   if (errorState == YES) return @"42:Server error";
   if (_activePlotKey == nil) return @"43:No plot selected";
   
   event = [[[_eventBuffer objectForKey:_activePlotKey] copy] autorelease];
   [_eventBuffer setObject:@"0" forKey:_activePlotKey];
   return event;
}

#pragma mark ==== AQTEventProtocol ====
- (void)ping
{
   return;
}

- (void)processEvent:(NSString *)event sender:(id)sender
{
   NSNumber *key;
   
   NSArray *keys = [_plots allKeysForObject:sender];
   if ([keys count] == 0) return;
   key = [keys objectAtIndex:0];

   if (_eventHandler != nil) {
      _eventHandler([key intValue], event);
   }
   [_eventBuffer setObject:event forKey:key];
}
@end
