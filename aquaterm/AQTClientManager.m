//
//  AQTClientManager.m
//  AquaTerm
//
//  Created by Per Persson on Wed Nov 19 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTClientManager.h"
#import "AQTPlotBuilder.h"
#import "AQTPlotController.h"

#import "AQTConnectionProtocol.h"

@implementation AQTClientManager
+ (AQTClientManager *)sharedManager
{
   static AQTClientManager *sharedManager = nil;
   if (sharedManager == nil)
   {
      sharedManager = [[self alloc] init]; 
   }
   return sharedManager;
}

- (id)init
{
   if(self = [super init])
   {
      char *envPtr;
      _builders = [[NSMutableDictionary alloc] initWithCapacity:256];
      _plotControllers = [[NSMutableDictionary alloc] initWithCapacity:256];
      _eventBuffer = [[NSMutableDictionary alloc] initWithCapacity:256];
      _logLimit = 0;
      // Read environment variable(s)
      envPtr = getenv("AQUATERM_LOGLEVEL");
      if (envPtr != (char *)NULL)
      {
         _logLimit = (int)strtol(envPtr, (char **)NULL, 10);
      }
      NSLog(@"LogLimit = %d", _logLimit);
      [self logMessage:[NSString stringWithFormat:@"Warning: Logging at level %d", _logLimit] logLevel:3];
   }
   return self;
}

- (void)dealloc
{
   [_activePlotKey release];
   [_eventBuffer release];
   [_builders release];
   [_plotControllers release];
   [super dealloc];
}
   
- (void)setServer:(id)server
{
   _server = server;
}

- (void)setActivePlotKey:(id)newActivePlotKey
{
   [newActivePlotKey retain];
   [_activePlotKey release];
   _activePlotKey = newActivePlotKey;
   [self logMessage:[NSString stringWithFormat:@"Active plot: %d", [_activePlotKey intValue]] logLevel:3];
}

- (BOOL)connectToServer
{
   BOOL didConnect = NO;
   _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
   if (!_server)
   {
      [self logMessage:@"Launching server..." logLevel:2];
      if (![self launchServer])
      {
         [self logMessage:@"Launching failed." logLevel:2];
      }
      else
      {
         // Wait for server to start up
         int timer = 10;
         while (--timer && !didConnect)
         {
            // sleep 1s
            [self logMessage:[NSString stringWithFormat:@"Waiting... %d", timer] logLevel:2];
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
            int a,b,c;
            [_server retain];
            [_server setProtocolForProxy:@protocol(AQTConnectionProtocol)];
            [_server getServerVersionMajor:&a minor:&b rev:&c];
            [self logMessage:[NSString stringWithFormat:@"Server version %d.%d.%d", a, b, c] logLevel:2];
            didConnect = YES;
         }
         else
         {
            [self logMessage:@"server is too old info" logLevel:1];
            _server = nil;
         }
      }
      NS_HANDLER
         if ([[localException name] isEqualToString:NSInvalidSendPortException])
            [self _aqtServerError:[localException name]];
         else
            [localException raise];
      NS_ENDHANDLER
      [self logMessage:didConnect?@"Connected!":@"Could not connect" logLevel:1];
      return didConnect;
}

// This is still troublesome... Needs to figure out if user is running from remote machine. NSTask
- (BOOL)launchServer
{
   NSURL *appURL;

   if (getenv("AQUATERM_PATH") == (char *)NULL)
   {
      // No, search for it in standard locations
      NSURL *tmpURL;
      appURL = (LSFindApplicationForInfo(NULL, NULL, (CFStringRef)@"AquaTerm.app", NULL, (CFURLRef *)&tmpURL) == noErr)?tmpURL:nil;
   }
   else
   {
      appURL = [NSURL fileURLWithPath:[NSString stringWithCString:getenv("AQUATERM_PATH")]];
   }
   return (LSOpenCFURLRef((CFURLRef)appURL, NULL) == noErr);
}

- (void)terminateConnection
{
   NSEnumerator *enumObjects = [[_plotControllers allKeys] objectEnumerator];
   id key;
   while (key = [enumObjects nextObject])
   {
      _activePlotKey = key;
      [self closePlot];
   }
   if([_server isProxy])
   {
      [_server release];
      _server = nil;
   }
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
   if (level > 0 && level <= _logLimit)
   {
      NSLog(msg);
   }
}

#pragma mark === Error handling methods ===

- (void)_aqtServerError:(NSString *)msg
{
   if (_errorHandler)
   {
      _errorHandler(msg);
   }
   else
   {
      [self logMessage:[NSString stringWithFormat:@"Server error: %@", msg] logLevel:1];
   }
}

- (void)_aqtHandlerError:(NSString *)msg
{
   // Do something!
   // [self closePlot];
   [self logMessage:[NSString stringWithFormat:@"Handler error: %@", msg] logLevel:1];
   // Test for server prescence
   NS_DURING
      [_server ping]; 
   NS_HANDLER
      // Dang! Server is borken
      [self _aqtServerError:[localException name]];
   NS_ENDHANDLER
}

#pragma mark === Plot/builder methods ===

- (NSNumber *)keyForPlotController:(AQTPlotController *)pc
{
   if (pc != nil)
   {
      NSArray *keys = [_plotControllers allKeysForObject:pc];
      if ([keys count] > 0)
      {
         return [keys objectAtIndex:0];
      }
   }
   return nil;
}

- (AQTPlotBuilder *)newPlotWithIndex:(int)refNum
{
   // FIXME
   AQTPlotBuilder *newBuilder;
   NSNumber *key = [NSNumber numberWithInt:refNum];
   AQTPlotController *pc = [[AQTPlotController alloc] init];
   id newHandler;
   NS_DURING
      newHandler = [_server addAQTClient:pc
                                    name:[[NSProcessInfo processInfo] processName]
                                     pid:[[NSProcessInfo processInfo] processIdentifier]];
   NS_HANDLER
      if ([[localException name] isEqualToString:NSInvalidSendPortException])
         [self _aqtServerError:[localException name]];
      else
         [localException raise];
   NS_ENDHANDLER
   if (newHandler)
   {
      // set active plot
      [self setActivePlotKey:key];
      [_plotControllers setObject:pc forKey:key];
      [pc setHandler:newHandler]; 
      // Also create a corresponding builder
      newBuilder = [[AQTPlotBuilder alloc] init];
      [_builders setObject:newBuilder forKey:key];
      [newBuilder release];
   }
   [pc release];
   return newBuilder;
}

- (AQTPlotBuilder *)selectPlotWithIndex:(int)refNum
{
   NSNumber *key = [NSNumber numberWithInt:refNum];
   AQTPlotBuilder *aBuilder = [_builders objectForKey:key];
   if(aBuilder != nil)
   {
      [self setActivePlotKey:key];
   }
   return aBuilder;
}

- (void)renderPlot 
{
   AQTPlotBuilder *pb = [_builders objectForKey:_activePlotKey];
   if ([pb modelIsDirty])
   {
      [[_plotControllers objectForKey:_activePlotKey] setModel:[pb model]];
   }
}

- (void)clearPlot
{
   [[_builders objectForKey:_activePlotKey] clearAll];
   [self renderPlot];
}

- (void)closePlot
{
   NS_DURING
      if ([_server removeAQTClient:[_plotControllers objectForKey:_activePlotKey]] == NO)
      {
         [self logMessage:@"Couldn't remove remote client lock, leaking" logLevel:1];
      }
   NS_HANDLER
      [self logMessage:@"Discarding exception..." logLevel:1];
   NS_ENDHANDLER
   [_plotControllers removeObjectForKey:_activePlotKey];
   [_builders removeObjectForKey:_builders];
   [self setActivePlotKey:nil];
}

- (void)setAcceptingEvents:(BOOL)flag 
{
   [[_plotControllers objectForKey:_activePlotKey] setAcceptingEvents:flag];
}

- (void)processEvent:(NSString *)event sender:(id)sender
{
   NSNumber *key = [self keyForPlotController:(AQTPlotController *)sender];
   if (_eventHandler != nil)
   {
      _eventHandler([key intValue], event);
   }
   [_eventBuffer setObject:event forKey:key];
}

- (NSString *)lastEvent 
{
   NSString *event;
   event = [[[_eventBuffer objectForKey:_activePlotKey] copy] autorelease];
   [_eventBuffer setObject:@"0" forKey:_activePlotKey];
   return event;
}
@end
