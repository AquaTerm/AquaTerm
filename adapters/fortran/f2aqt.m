#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTProtocol.h"
//
// Fortran interface (_not_complete, just an example!!!) 
//
int f2aqt_init__(void);
int f2aqt_info__(int *x, int *y);
int f2aqt_reset__(void);
int f2aqt_render__(void);
int f2aqt_color__(int *color);
int f2aqt_move__(int *x, int *y);
int f2aqt_vector__(int *x, int *y);
int f2aqt_justify__(int *justification);
int f2aqt_put_text__(int *x, int *y, const char *str);

static NSAutoreleasePool *arpool;   // our autorelease pool 
static id gnuTermAccess;        	// local object manages the D.O. connection
static int currentWindow = 0;		// the only option to set (could be set _before_ instatiation of gnuTermAccess)

/*
 * The class NSBezierPath doesn't implement replacementObjectForPortCoder so
 * we add that behaviour as a category for NSBezierPath
 */
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

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}


#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */

// ----------------------------------------------------------------
// AQTAdapter - A class to mediate between gnuplot C-function calls
// and AquaTerm Objective-C remote messages
// ----------------------------------------------------------------
//
@interface AQTAdapter : NSObject
{
  @private
  id server;
  NSMutableDictionary *termInfo;
  NSBezierPath *thePath;
  int justificationMode;
  int linetype;
  double gray;
  float textAngle;
  int figure;
}
-(id) init;
-(void) dealloc;
-(id) server;
-(NSMutableDictionary *)termInfo;
-(void) invalidateServer;
-(BOOL) connectToServer;
-(void) updateInfoFromServer;
-(void) flushOrphanedGraphicsRender:(BOOL)shouldRender release:(BOOL)shouldRelease;
-(void) moveToPoint:(NSPoint)point;
-(void) lineToPoint:(NSPoint)point;
-(void) setLinetype:(int)linetype;
-(void) putText:(const char *)str at:(NSPoint)point;
-(void) setJustification:(int)mode;
-(void) setTextAngle:(int)angle;
-(void) setFont:(const char *)font;
-(void) fillRect:(NSRect)rect style:(int)style;
-(void) setLinewidth:(double)linewidth;
-(void) setFillColor:(double)gray;
// -(void) setPolygonUsing:(int)count corners:(gpiPoint *)corners;
-(void) setFigure:(int)newFigure;
@end 

@implementation AQTAdapter
-(id) init
{
  if (self = [super init])
  {
    thePath = [[NSBezierPath alloc] init];
    termInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    justificationMode = 0;
    linetype = 0;
    gray = 0.0;
    textAngle = 0.0;
    figure = currentWindow;	/* Current window could have changed before */
    if ([self connectToServer])
    {
      [server setProtocolForProxy:@protocol(AQTProtocol)];
      [self updateInfoFromServer];
    }
  }
  return self;
}

-(void) dealloc
{
  [termInfo release];
  [thePath release];
  [server release];
  [super dealloc];
}

-(id) server
{
  return server;
}
-(NSMutableDictionary *)termInfo
{
  return termInfo;
}
-(void) invalidateServer
{
  [server release];
  server = nil;
  currentWindow = 0;
  printf("Lost connection to server,\nuse \"set term aqua <n>\" to reconnect.\n");
}

-(BOOL) connectToServer
{
  BOOL defaultApp = YES;
  BOOL didConnect = NO;
  NSString *appString;
  /*
   * Establish a connection to graphics terminal (server)
   * First check if a  server is registered already
   * If not, check if environment variable GNUTERMAPP is set
   * and try to launch that application
   * Finally default to looking for a hardcoded app in
   * standard locations.
   */
  server = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
  if (server) /* Server is running ready to go */
  {
    [server retain];
    didConnect = YES;
  }
  else /* Server isn't running, we must fire it up */
  {
    if (getenv("GNUTERMAPP") == (char *)NULL)
    {
      appString = [NSString stringWithString:@"AquaTerm"];
    }
    else
    {
      appString = [NSString stringWithCString:getenv("GNUTERMAPP")];
      defaultApp = NO;
    }
    /* Try to launch application */
    if ([[NSWorkspace sharedWorkspace] launchApplication:appString] == NO)
    {
      printf("Failed to launch gnuplot server.\n");
      if (defaultApp)
      {
        printf("You must either put the server application in \n");
        printf("the /Applications folder, ~/Applications folder\n");
        printf("or set the environment variable GNUTERMAPP to the\n");
        printf("full path of the server application, e.g.\n");
        printf("setenv GNUTERMAPP \"/some/strange/location/MyServer.app\"\n");
      }
      else
      {
        printf("Check environment variable GNUTERMAPP for errors\n");
      }
    }
    else
    {
      do { /* Wait for it to register Server methods with OS */
        server =[NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
      } while (!server);  /* This could result in a hang... */
      [server retain];
      didConnect = YES;
   	}
  }
  if (didConnect)
  {
    [server setProtocolForProxy:@protocol(AQTProtocol)];
    [self updateInfoFromServer];
  }
  return didConnect;
}

-(void) updateInfoFromServer
{
  NS_DURING	/* try */
    [termInfo  setDictionary:[server getAquaTermInfo]];
  NS_HANDLER 
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"]) 
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
}

-(void) flushOrphanedGraphicsRender:(BOOL)shouldRender release:(BOOL)shouldRelease
{
  NS_DURING
    if ([thePath isEmpty] == NO)
    {
      [server addPolyline:thePath withIndexedColor:linetype];
      [thePath removeAllPoints];
    }
    if (shouldRender)
    {
      [server renderInViewShouldRelease:shouldRelease];
    }
    NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
        [self invalidateServer];
      else
        [localException raise];
    NS_ENDHANDLER
}

-(void) moveToPoint:(NSPoint)point
{
  [thePath moveToPoint:point];
}

-(void) lineToPoint:(NSPoint)point
{
  [thePath lineToPoint:point];
}

-(void) setLinetype:(int)newLinetype
{
  if (newLinetype != linetype)
  {
    [self flushOrphanedGraphicsRender:NO release:NO];
    linetype = newLinetype;
  }
}

-(void) putText:(const char *)str at:(NSPoint)point
{
  NS_DURING
    [server addString:[NSString stringWithCString:str]
              atPoint:point
    withJustification:justificationMode
              atAngle:textAngle
     withIndexedColor:linetype];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
}

-(void) setJustification:(int)mode
{
  justificationMode = mode;
}

-(void) setTextAngle:(int)angle
{
  if (angle==0)
  {
    textAngle = 0.0;
  }
  else
  {
    textAngle = 90.0;
  }
}

-(void) setFont:(const char *)font
{
  NSArray *tempArray = [NSArray arrayWithArray:[[NSString stringWithCString:font] componentsSeparatedByString:@","]];
  // FIXME: Check up on why setFont always is followed by a call with an empty string.
  NS_DURING
  switch ([tempArray count])
  {
    case 2:
      [server setFontWithName:[tempArray objectAtIndex:0] size:[[tempArray objectAtIndex:1] floatValue]];
      break;
    case 1:
      if ([[tempArray objectAtIndex:0] isEqualToString:@""])
      {
        [server setFontWithName:[termInfo objectForKey:@"AQTDefaultFontName"] size:[[termInfo objectForKey:@"AQTDefaultFontSize"] floatValue]];
      }
      else
      {
        [server setFontWithName:[tempArray objectAtIndex:0] size:[[termInfo objectForKey:@"AQTDefaultFontSize"] floatValue]];
      }
      break;
    case 0:
        // fallthrough
    default:
      [server setFontWithName:[termInfo objectForKey:@"AQTDefaultFontName"] size:[[termInfo objectForKey:@"AQTDefaultFontSize"] floatValue]];
    break;
  }
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
  //
  // Read back the new font info. (Not neccessarily what we wanted ;-)
  //
  [self updateInfoFromServer];
}

-(void) fillRect:(NSRect)rect style:(int)style
{
  [self flushOrphanedGraphicsRender:NO release:NO];
  NS_DURING
    [server clearRect:rect];
    [server renderInViewShouldRelease:NO];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
}

-(void) setLinewidth:(double)linewidth
{
  [thePath setLineWidth:linewidth];
}

-(void) setFillColor:(double)newGray
{
  /* FIXME: Should allow for a color resolution to improve speed */
  [self flushOrphanedGraphicsRender:NO release:NO];
  gray = newGray;
}

/*
-(void) setPolygonUsing:(int)count corners:(gpiPoint *)corners
{
  int i;
  NS_DURING
    [thePath moveToPoint:NSMakePoint(corners[0].x, corners[0].y)];
    for (i=1;i< count;i++)
    {
      [thePath lineToPoint:NSMakePoint(corners[i].x, corners[i].y)];
    }
    [thePath closePath];
    [server addPolygon:thePath withColor:gray];
    [thePath removeAllPoints];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
}
*/
-(void) setFigure:(int)newFigure
{
  figure = newFigure;
  NS_DURING
    [server selectModel:figure];
  NS_HANDLER
    if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
      [self invalidateServer];
    else
      [localException raise];
  NS_ENDHANDLER
}
@end /* AQTAdapter */
//
// ----------------------------------------------------------------
// FORTRAN driver example
// ----------------------------------------------------------------
//
int f2aqt_init__(void)
{
  LOG(@"int f2aqt_init__(void)");
  if (arpool == NULL)   /* Make sure we don't leak mem by allocating every time */
  {
    arpool = [[NSAutoreleasePool alloc] init]; 
    gnuTermAccess = [[AQTAdapter alloc] init]; 
  }
  if (![gnuTermAccess server])	/* server could be invalid (=nil) for several reasons */
  {
    [gnuTermAccess connectToServer];
  }

  [gnuTermAccess setFigure:currentWindow];
}

int f2aqt_info__(int *x_size, int *y_size)
{
  *x_size = [[[gnuTermAccess termInfo] objectForKey:@"AQTXMax"] intValue]; 
  *y_size = [[[gnuTermAccess termInfo] objectForKey:@"AQTYMax"] intValue]; 
}

int f2aqt_render__(void)
{ 
  [gnuTermAccess flushOrphanedGraphicsRender:YES release:YES];
}

int f2aqt_reset__(void)
{
  [gnuTermAccess flushOrphanedGraphicsRender:NO release:YES];
  [gnuTermAccess flushOrphanedGraphicsRender:NO release:YES];
}

int f2aqt_vector__(int *x, int *y)
{
  [gnuTermAccess lineToPoint:NSMakePoint(*x, *y)];
}

int f2aqt_color__(int *color)
{
  [gnuTermAccess setLinetype:*color];
}

int f2aqt_justify__(int *justification)
{
  [gnuTermAccess setJustification:*justification];
}

int f2aqt_move__(int *x, int *y)
{
  [gnuTermAccess moveToPoint:NSMakePoint(*x, *y)];
}


int f2aqt_put_text__(int *x, int *y, const char *str)
{
  if (!strlen(str))
    return;
  [gnuTermAccess putText:str at:NSMakePoint(*x, *y)];
}



