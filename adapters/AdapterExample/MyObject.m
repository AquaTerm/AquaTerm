#import "MyObject.h"
#import "AQTProtocol.h"

#define justifyLeft 0
#define justifyCenter 1
#define justifyRight 2
//
// FIXME! These are "magic numbers", a real nono
//
#define AQUA_XMAX (11.69*72.0)    /* paper width times screen resolution. 11.69*72 = 841.68 */
#define AQUA_YMAX (8.26*72.0)	/* paper height times screen resolution. 8.26*72 = 594.72 */


//
// Private methods neccessary for passing bezier path to AquaTerm
//
@interface NSBezierPath (NSBezierPathDOCategory)
- (id)replacementObjectForPortCoder:(NSPortCoder *)portCoder; 
@end

@implementation NSBezierPath (NSBezierPathDOCategory)
- (id)replacementObjectForPortCoder:(NSPortCoder *)portCoder 
{
	if ([portCoder isBycopy]) 
		return self;
	return [super replacementObjectForPortCoder:portCoder];
}
@end


@implementation MyObject 
- (IBAction)connectAction:(id)sender
{
    //
    // Check if we have a connection already
    //
    if (nil==server)
    {
      //
      // Try to establish connection
      //
      server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
      if (nil==server)
      {
        //
        //	We could start up AquaTerm programmatically here, but it is just an example!
        //
        [statusOutlet setStringValue:@"Please start up AquaTerm first!"];
      }
      else
      {
        //
        // OK!
        //
        [server retain];
        [statusOutlet setStringValue:@"Connected to AquaTerm!"];
        //
        // Get the server/protocol version
        //
        if([server respondsToSelector:@selector(getAquaTermInfo)])
        {
          NSLog(@"Dictionary: \n%@", [server getAquaTermInfo]);
        } 
        else
        {
          NSLog(@"Warning --- AQTProtocol v0.1.0, you should update AquaTerm");
        }
        //
        // Make sure we get notified when things happen to the server
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(serverDidCloseConnection:)
                                              name:NSConnectionDidDieNotification
                                              object:[server connectionForProxy]];
        //
        // Set the protocol for the conversation
        //
        [server setProtocolForProxy:@protocol(AQTProtocol)];
        //
        // Select a model to write to and show the corresponding window
        // (will create the window if neccessary)
        //
        [server selectModel:1];
        [server renderInViewShouldRelease:YES];
      }
    }
    else
    {
      [statusOutlet setStringValue:@"Already connected to AquaTerm!"];
    }
}



- (IBAction)addPathAction:(id)sender
{
    NSPoint aPoint = NSMakePoint(AQUA_XMAX*randomNumber(), AQUA_YMAX*randomNumber());
    NSBezierPath *aPath = [NSBezierPath bezierPath];
    
    [aPath moveToPoint:aPoint];
    do {
      aPoint = NSMakePoint(AQUA_XMAX*randomNumber(), AQUA_YMAX*randomNumber());
      [aPath lineToPoint:aPoint];
    } while (randomNumber() < 0.8);
    
    if (randomNumber() < 0.5)
    {
      // Polygon
       [server addPolygon:aPath withColor:randomNumber() /* [0..1] */];  
    }
    else
    {
      // Polyline
      [server addPolyline:aPath withIndexedColor:(int)(8*randomNumber()) /* {0,1,...,7} */];
    } 
    [server renderInViewShouldRelease:NO];
}

- (IBAction)setFontAction:(id)sender
{
    NSString *fontNameString = [NSString stringWithString:[fontFieldOutlet stringValue]];
    [server setFontWithName:fontNameString size:18.0];
}

- (IBAction)addTextAction:(id)sender
{
  NSPoint aPoint= NSMakePoint(AQUA_XMAX*randomNumber(), AQUA_YMAX*randomNumber());
  [server addString:@"Hello world!" 
          atPoint:aPoint 
          withJustification:justifyLeft 
          withIndexedColor:(int)(8*randomNumber()) /* {0,1,...,7} */];
          
  [server renderInViewShouldRelease:NO];
}

- (IBAction)releaseAction:(id)sender
{
  [server renderInViewShouldRelease:YES];
}

- (void)serverDidCloseConnection:(NSNotification *)notification
{
    NSLog(@"Notification: -serverDidCloseConnection");
    [statusOutlet setStringValue:@"Not connected to AquaTerm"];
    server = nil;
}
- (void)gotNotification:(NSNotification *)notification
{
    NSLog(@"Notification name = %@", [notification name]);
}


float randomNumber(void)
{
  float   randSeed = (float)rand(); 	// get a random int, 0 to 2^32
  return randSeed/2147483648.0; 		// divide it by 2^32 to get a [0 1] range
}
@end
