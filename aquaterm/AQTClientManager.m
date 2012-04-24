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
   printf("AquaTerm warning: Connection to display was lost,\n");
   printf("plot commands will be discarded until a new plot is started.\n");
}

- (void)clearErrorState
{
   BOOL serverDidDie = NO;

   [self logMessage:@"Trying to recover from error." logLevel:3];

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
         _logLimit = (int32_t)strtol(envPtr, (char **)NULL, 10);
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
   return [self connectToServerWithName:@"aquatermServer"];
}

- (BOOL)connectToServerWithName:(NSString *)registeredName
{
[self logMessage:@"Trying to connect..." logLevel:2];
   // FIXME: Check to see if _server exists.
   BOOL didConnect = NO;
   _server = [NSConnection rootProxyForConnectionWithRegisteredName:registeredName host:nil];
   if (!_server) {
      [self logMessage:@"Launching server..." logLevel:2];
      if (![self launchServer]) {
         [self logMessage:@"Launching failed." logLevel:2];
      } else {
         // Wait for server to start up
         int32_t timer = 10;
         while (--timer && !_server) {
            // sleep 1s
            [self logMessage:[NSString stringWithFormat:@"Waiting... %d", timer] logLevel:2];
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            // check for server connection
            _server = [NSConnection rootProxyForConnectionWithRegisteredName:registeredName host:nil];
         }
      }
   }
   if (_server) {
      NS_DURING
         if ([_server conformsToProtocol:@protocol(AQTConnectionProtocol)]) {
            int32_t a,b,c;
             [_server retain];
            [_server setProtocolForProxy:@protocol(AQTConnectionProtocol)];
            [_server getServerVersionMajor:&a minor:&b rev:&c];
            [self logMessage:[NSString stringWithFormat:@"Server version %d.%d.%d", a, b, c] logLevel:2];
            didConnect = YES;
         } else {
            [self logMessage:@"server is too old info" logLevel:1];
            _server = nil;
         }
         NS_HANDLER
            // [localException raise];
            [self logMessage:@"An error occurred while talking to the server" logLevel:1];
         NS_ENDHANDLER
   }
   [self logMessage:didConnect?@"Connected!":@"Could not connect" logLevel:1];
   return didConnect;
}

// This is still troublesome... Needs to figure out if user is running from remote machine. NSTask
- (BOOL)launchServer
{
   NSURL *appURL;
   OSStatus status;
   
    if (getenv("AQUATERM_PATH") != (char *)NULL) {
       appURL = [NSURL fileURLWithPath:[NSString stringWithCString:getenv("AQUATERM_PATH") encoding: NSUTF8StringEncoding]];
      status = LSOpenCFURLRef((CFURLRef)appURL, NULL);
   } else {
      // Look for AquaTerm at default location
      status = LSOpenCFURLRef((CFURLRef)[NSURL fileURLWithPath:@"/Applications/AquaTerm.app"], NULL);
      if (status != noErr) {
         // No, search for it based on creator code, choose latest version
         NSURL *tmpURL;
         status = LSFindApplicationForInfo('AqTS', NULL, NULL, NULL, (CFURLRef *)&tmpURL);
         [self logMessage:[NSString stringWithFormat:@"LSFindApplicationForInfo = %d", status] logLevel:2];
         appURL = (status == noErr)?tmpURL:nil;
         [appURL autorelease];
         status = LSOpenCFURLRef((CFURLRef)appURL, NULL);
      }
   }
   [self logMessage:[NSString stringWithFormat:@"LSOpenCFURLRef = %d", status] logLevel:2];
   return (status == noErr);
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
   [self logMessage:@"Terminating connection." logLevel:1];
}

#pragma mark ==== Accessors ====

- (void)setActivePlotKey:(id)newActivePlotKey
{
   [newActivePlotKey retain];
   [_activePlotKey release];
   _activePlotKey = newActivePlotKey;
   [self logMessage:_activePlotKey?[NSString stringWithFormat:@"Active plot: %d", [_activePlotKey integerValue]]:@"**** plot invalid ****"
           logLevel:3];
}

- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr
{
   _errorHandler = fPtr;
}

- (void)setEventHandler:(void (*)(int32_t index, NSString *event))fPtr
{
   _eventHandler = fPtr;
}

- (void)logMessage:(NSString *)msg logLevel:(int32_t)level
{
   // _logLimit: 0 -- output off
   //            1 -- severe errors
   //            2 -- user debug
   //            3 -- noisy, dev. debug
   if (level > 0 && level <= _logLimit) {
      NSLog(@"\nlibaquaterm::%@", msg);
   }
}

#pragma mark === Plot/builder methods ===

- (AQTPlotBuilder *)newPlotWithIndex:(int32_t)refNum
{
   AQTPlotBuilder *newBuilder = nil;
   NSNumber *key = [NSNumber numberWithInteger:refNum];;
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
      // [localException raise];
      [self _aqtHandlerError:[localException name]];
      newPlot = nil;
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

- (AQTPlotBuilder *)selectPlotWithIndex:(int32_t)refNum
{
   NSNumber *key;
   AQTPlotBuilder *aBuilder;
 
   if (errorState == YES) return nil; // FIXME: Clear error state here too???

   key = [NSNumber numberWithInteger:refNum];
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
         // [localException raise];
         [self _aqtHandlerError:[localException name]];
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
      // [localException raise];
      [self _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
   [newBuilder release];
   return newBuilder;
}

- (void)clearPlotRect:(NSRect)aRect 
{
   AQTPlotBuilder *pb;
   AQTRect aqtRect;
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
      // 64 bit compatibility
      aqtRect.origin.x = aRect.origin.x;
      aqtRect.origin.y = aRect.origin.y;
      aqtRect.size.width = aRect.size.width;
      aqtRect.size.height = aRect.size.height;
      [thePlot removeGraphicsInRect:aqtRect];
      // [thePlot draw];
   NS_HANDLER
      // [localException raise];
      [self _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
}

- (void)closePlot
{
   if (_activePlotKey == nil) return;

   NS_DURING
      [[_plots objectForKey:_activePlotKey] setClient:nil];
      [[_plots objectForKey:_activePlotKey] close];
   NS_HANDLER
      [self logMessage:@"Closing plot, discarding exception..." logLevel:2];
   NS_ENDHANDLER
   [_plots removeObjectForKey:_activePlotKey];
   [_builders removeObjectForKey:_activePlotKey];
   [self setActivePlotKey:nil];
}

#pragma mark ==== Events ====

- (void)setAcceptingEvents:(BOOL)flag  
{
   if (errorState == YES || _activePlotKey == nil) return;
   NS_DURING
      [[_plots objectForKey:_activePlotKey] setAcceptingEvents:flag];
   NS_HANDLER
      [self _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
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
      _eventHandler([key integerValue], event);
   }
   [_eventBuffer setObject:event forKey:key];
}

#pragma mark ==== Testing methods ====
- (void)timingTestWithTag:(uint32_t)tag
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
         [thePlot timingTestWithTag:tag];
      NS_HANDLER
         // [localException raise];
         [self _aqtHandlerError:[localException name]];
      NS_ENDHANDLER
   }
}
@end
