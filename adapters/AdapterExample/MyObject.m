#import "MyObject.h"
#import "gptProtocol.h"


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
      server = [NSConnection rootProxyForConnectionWithRegisteredName:@"gnuplotServer" host:nil];
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
        // Open a window
        //
        [server gptCurrentWindow:1];
        [server gptRenderRelease:YES];
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
    int strokeColor = (int)randomNumber()*8;	// Eight fixed colors
    double fillColor =  randomNumber();			// Colormap [0 1]
    
    [aPath moveToPoint:aPoint];
    do {
      aPoint = NSMakePoint(AQUA_XMAX*randomNumber(), AQUA_YMAX*randomNumber());
      [aPath lineToPoint:aPoint];
    } while (randomNumber() < 0.8);
    
    if (randomNumber() < 0.5)
    {
      // Fill path
       [server gptSetPath:aPath WithLinetype:strokeColor FillColor:fillColor PathIsFilled:YES];     
    }
    else
    {
      // Stroke path
      [server gptSetPath:aPath WithLinetype:strokeColor FillColor:0 PathIsFilled:NO];
    } 
    [server gptRenderRelease:NO];
}

- (IBAction)addTextAction:(id)sender
{
  NSPoint aPoint= NSMakePoint(AQUA_XMAX*randomNumber(), AQUA_YMAX*randomNumber());
  int aColor = (int)randomNumber()*8; // Eight fixed colors		

  [server gptPutString:@"Hello world!" AtPoint:aPoint WithJustification:justifyLeft WithLinetype:aColor];
  [server gptRenderRelease:NO];
}
- (IBAction)releaseAction:(id)sender
{
  [server gptRenderRelease:YES];
}

float randomNumber(void)
{
  float   randSeed = (float)rand(); 	// get a random int, 0 to 2^32
  return randSeed/2147483648.0; 		// divide it by 2^32 to get a [0 1] range
}
@end
