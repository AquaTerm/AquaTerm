#import "AQTAdapterPrivateMethods.h"


@implementation AQTAdapter (AQTAdapterPrivateMethods)
- (BOOL)_connectToServer
{

   BOOL didConnect = NO;
   _server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
   if (!_server)
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
            NSLog(@"Waiting... %d", timer);
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
            NSLog(@"Server version %d.%d.%d", a, b, c);
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
            [self _serverError:[localException name]];
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
   }
   return (LSOpenCFURLRef((CFURLRef)appURL, NULL) == noErr);
}

- (void)_serverError:(NSString *)msg
{
   if (_errorHandler)
   {
      _errorHandler(msg);
   }
   else
   {
      NSLog(@"Server error: %@", msg);   
   }
}

- (void)_handlerError:(NSString *)msg
{
   NS_DURING
      // Test for server prescence
      [_server ping];
   NS_HANDLER
      // Dang! Server is borken
      [self _serverError:[localException name]];
   NS_ENDHANDLER
   if (_errorHandler)
   {
      _errorHandler(msg);
   }
   else
   {
      NSLog(@"Handler error: %@", msg);
      [self closePlot];
   }
}
@end
