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
- (void)_aqtHandlerError:(NSString *)msg
{
   // FIXME: stuff @"42:Server error" in all event buffers/handlers ?
   [self logMessage:[NSString stringWithFormat:@"Handler error: %@", msg] logLevel:1];
   errorState = YES;
}

- (void)clearErrorState
{
   BOOL serverDidDie = NO;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   NS_DURING
      [_server ping];
   NS_HANDLER
      [self logMessage:@"Server not responding." logLevel:1];
      serverDidDie = YES;
   NS_ENDHANDLER

   if (serverDidDie)
   {
      [self terminateConnection];
   }
   else
   {
      [self closePlot];
   }
   errorState = NO;
}

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
      // NSLog(@"LogLimit = %d", _logLimit);
      [self logMessage:[NSString stringWithFormat:@"Warning: Logging at level %d", _logLimit] logLevel:1];
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
   [self logMessage:_activePlotKey?[NSString stringWithFormat:@"Active plot: %d", [_activePlotKey intValue]]:@"**** plot invalid ****"
           logLevel:3];
}

- (BOOL)connectToServer
{
   // FIXME: Check to see if _server exists.
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
         while (--timer && !_server)
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
         /*
         if ([[localException name] isEqualToString:NSInvalidSendPortException])
            [self _aqtServerError:[localException name]];
         else
            [localException raise];
          */
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

   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);   

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

#pragma mark === Plot/builder methods ===

- (NSNumber *)keyForPlotController:(AQTPlotController *)pc
{
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
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
   AQTPlotBuilder *newBuilder;
   NSNumber *key;
   AQTPlotController *pc;
   id newHandler;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (errorState == YES)
   {
      [self clearErrorState];
      if (_server == nil)
         [self connectToServer];
   }
   
   key = [NSNumber numberWithInt:refNum];
   pc = [[AQTPlotController alloc] init];

   NS_DURING
      newHandler = [_server addAQTClient:pc
                                    name:[[NSProcessInfo processInfo] processName]
                                     pid:[[NSProcessInfo processInfo] processIdentifier]];
   NS_HANDLER
/*
 if ([[localException name] isEqualToString:NSInvalidSendPortException])
         [self _aqtServerError:[localException name]];
      else
         [localException raise];
*/
      //NSLog([localException name]);
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
   NSNumber *key;
   AQTPlotBuilder *aBuilder;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (errorState == YES) return nil; // FIXME: Clear error state here too???

   key = [NSNumber numberWithInt:refNum];
   aBuilder = [_builders objectForKey:key];

   if(aBuilder != nil)
   {
      [self setActivePlotKey:key];
   }
   return aBuilder;
}

- (void)renderPlot // FIXME: check _activePlotKey
{
   AQTPlotBuilder *pb;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (errorState == YES || _activePlotKey == nil) return;

   pb = [_builders objectForKey:_activePlotKey];
   if ([pb modelIsDirty])
   {
      AQTPlotController *pc = [_plotControllers objectForKey:_activePlotKey];
      [pc updatePlotWithModel:[pb model]];
      [pc drawPlot];
      if ([pc handlerIsProxy])
      {
         [pb removeAllParts];
      }
   }
}

- (void)clearPlot  // FIXME: check _activePlotKey
{
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (errorState == YES || _activePlotKey == nil) return;

   [[_builders objectForKey:_activePlotKey] clearAll];
   [[_plotControllers objectForKey:_activePlotKey] setShouldAppendPlot:NO];
   [self renderPlot];
}

- (void)clearPlotRect:(NSRect)aRect  // FIXME: check _activePlotKey
{
   AQTPlotBuilder *pb;
   AQTPlotController *pc;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (errorState == YES || _activePlotKey == nil) return;

   pb = [_builders objectForKey:_activePlotKey];
   pc = [_plotControllers objectForKey:_activePlotKey];

   if ([pb modelIsDirty])
   {
      [pc updatePlotWithModel:[pb model]]; // Push any pending output to the viewer, don't draw
      if ([pc handlerIsProxy])
      {
         [pb removeAllParts];
      }
   }
   // FIXME make sure in server that this combo doesn't draw unnecessarily
   [pc clearPlotRect:aRect];
   // [pc draw];
}

- (void)closePlot
{
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (_activePlotKey == nil)
   {
      // NSLog(@"_activePlotKey == nil, discards...");
      return;
   }
   NS_DURING
      if ([_server removeAQTClient:[_plotControllers objectForKey:_activePlotKey]] == NO)
      {
         [self logMessage:@"Couldn't remove remote client lock, leaking" logLevel:1];
      }
   NS_HANDLER
      [self logMessage:@"Discarding exception..." logLevel:1];
   NS_ENDHANDLER
   [_plotControllers removeObjectForKey:_activePlotKey];
   [_builders removeObjectForKey:_activePlotKey];
   [self setActivePlotKey:nil];
}

- (void)setAcceptingEvents:(BOOL)flag  // FIXME: check _activePlotKey
{
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   if (errorState == YES || _activePlotKey == nil) return;
   [[_plotControllers objectForKey:_activePlotKey] setAcceptingEvents:flag];
}

- (void)processEvent:(NSString *)event sender:(id)sender
{
   // FIXME: Check for nil-key, possibly embedd -keyForPlotController: code here.
   NSNumber *key = [self keyForPlotController:(AQTPlotController *)sender];
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (_activePlotKey == nil) return;

   if (_eventHandler != nil)
   {
      _eventHandler([key intValue], event);
   }
   [_eventBuffer setObject:event forKey:key];
}

- (NSString *)lastEvent  // FIXME: check _activePlotKey
{
   NSString *event;
   // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);

   if (errorState == YES) return @"42:Server error";
   if (_activePlotKey == nil) return @"43:No plot selected";
   
   event = [[[_eventBuffer objectForKey:_activePlotKey] copy] autorelease];
   [_eventBuffer setObject:@"0" forKey:_activePlotKey];
   return event;
}
@end
