#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTProtocol.h"
#include "f2aqt.h"
// 
// 
static NSAutoreleasePool *arpool; // Objective-C autorelease pool  
static id adapter;        				// Adapter object 
//
// ----------------------------------------------------------------
// --- Objective-C Adapter for AquaTerm 
// ----------------------------------------------------------------
//
// First we need some Cocoa magic incantations, documented at:
// http://developer.apple.com/techpubs/macosx/Cocoa/TasksAndConcepts/ProgrammingTopics/DistrObjects/
// Look under "Making Substitutions During Message Encoding"
//
// The class NSBezierPath doesn't implement replacementObjectForPortCoder so
// we add that behaviour as a category for NSBezierPath
//
@interface NSBezierPath (NSBezierPathDOCategory)
-(id)replacementObjectForPortCoder:(NSPortCoder *)portCoder;
@end

@implementation NSBezierPath (NSBezierPathDOCategory)
-(id)replacementObjectForPortCoder:(NSPortCoder *)portCoder
{
  if ([portCoder isBycopy])
    return self;
  return [super replacementObjectForPortCoder:portCoder];
}
@end
//
// ----------------------------------------------------------------
// --- AQTAdapter - A class to mediate between C-function calls
// --- and AquaTerm Objective-C remote messages
// ----------------------------------------------------------------
//
@interface AQTAdapter : NSObject
{
  NSBezierPath *filledPathBuffer;
  NSBezierPath *pathBuffer;
  NSMutableDictionary *termInfo;
  float linewidth;
  int orient;
  int just;
  int colorIndex;
  @private
  id aqtConnection;
}
-(id)aqtConnection;
-(NSMutableDictionary *)termInfo;
-(BOOL)connectToAquaTerm;	
-(void)updateInfoFromServer;
//
// Obj-C methods implementing the functionality defined in C_API.h
//
-(void)openGraph:(int)n;
-(void)closeGraph;
-(void)render;
-(void)setTitle:(NSString *)title;
-(void)setColor:(NSColor *)color forIndex:(int)index;
-(void)useColor:(int)index;
-(void)useLinewidth:(float)width;
-(void)appendPath:(NSBezierPath *)path;
-(void)appendFilledPath:(NSBezierPath *)path;
-(void)setFontWithName:(NSString *)name size:(float)size;
-(void)useOrientation:(int)orient;
-(void)useJustification:(int)just;
-(void)lineFromPoint:(NSPoint)startpoint toPoint:(NSPoint)endpoint;
-(void)putText:(NSString *)str at:(NSPoint)point;
-(void)addImageFromFile:(NSString *)filename  bounds:(NSRect)bounds;
//
-(void)flushBuffers;

@end 

@implementation AQTAdapter
-(id)init
{
  if (self = [super init])
  {
    filledPathBuffer = [[NSBezierPath alloc] init];
    pathBuffer = [[NSBezierPath alloc] init];
    termInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    //
    // Try to get a local proxy of the object in AquaTerm that manages communication
    // 
    if ([self connectToAquaTerm])
    {
      // 
      // This speeds up communication with the remote object, see
      // http://developer.apple.com/techpubs/macosx/Cocoa/TasksAndConcepts/ProgrammingTopics/DistrObjects/
      // Look under "Connections and Proxies"
      //
      [aqtConnection setProtocolForProxy:@protocol(AQTProtocol)];
    }
  }
  return self;
}

-(void)dealloc
{
  [aqtConnection release];
  [filledPathBuffer release];
  [pathBuffer release];
  [termInfo release];
  [super dealloc];
}

-(id)aqtConnection
{
  return aqtConnection;
}

-(NSMutableDictionary *)termInfo
{
  return termInfo;
}

-(BOOL)connectToAquaTerm
{
  BOOL didConnect = NO;
  //
  // Establish a connection to AquaTerm.
  // First check if AquaTerm is already running, otherwise
  // try to launch AquaTerm from standard locations.
  //
  aqtConnection = [NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
  if (aqtConnection) /* Server is running and ready to go */
  {
    [aqtConnection retain];
    didConnect = YES;
  }
  else /* Server isn't running, we must fire it up */
  {
    //
    // Try to launch AquaTerm
    //
    if ([[NSWorkspace sharedWorkspace] launchApplication:@"AquaTerm"] == NO)
    {
      printf("Failed to launch AquaTerm.\n");
      printf("You must either put AquaTerm.app in \n");
      printf("the /Applications or ~/Applications folder\n");
    }
    else
    {
      do { /* Wait for it to register with OS */
        aqtConnection =[NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
      } while (!aqtConnection);  /* This could result in a hang if something goes wrong with registering! */
      [aqtConnection retain];
      didConnect = YES;
   	}
  }
  return didConnect;
}
-(void) updateInfoFromServer
{
    [termInfo setDictionary:[aqtConnection getAquaTermInfo]];
}

//
// Adapter methods, this is where the translation takes place!
//
// The methods known to AquaTerm are defined in AQTProtocol.h
//
-(void)openGraph:(int)n
{
  // Set default values
  linewidth = 1;
  orient = 0;
  just = 1;
  colorIndex = 0;
  [aqtConnection openModel:n];
}

-(void)closeGraph
{
  [self flushBuffers];
  [aqtConnection closeModel];
}

-(void)render
{
  [self flushBuffers];
  [aqtConnection render];
}

-(void)setTitle:(NSString *)title
{
  [aqtConnection setTitle:title];
}

-(void)setColor:(NSColor *)color forIndex:(int)index
{
  [aqtConnection setColor:color forIndex:index];
}
-(void)useColor:(int)index
{
  // flush buffers before changing color...
  if(index != colorIndex)
  {
    [self flushBuffers];
    colorIndex = index;
  }
  
}

-(void)useLinewidth:(float)width
{
  // flush buffers before changing linewidth...
  if(width != linewidth)
  {
    [self flushBuffers];
    linewidth = width;
  }
}

-(void)appendPath:(NSBezierPath *)path
{
  [pathBuffer appendBezierPath:path];
}

-(void)appendFilledPath:(NSBezierPath *)path
{
  [filledPathBuffer appendBezierPath:path];
}

-(void)setFontWithName:(NSString *)name size:(float)size
{
  [aqtConnection setFontWithName:name size:size];
}

-(void)useOrientation:(int)newOrient
{
  orient = newOrient;
}

-(void)useJustification:(int)newJust
{
    just = newJust;
}

-(void)lineFromPoint:(NSPoint)startpoint toPoint:(NSPoint)endpoint
{
  [pathBuffer moveToPoint:startpoint];
  [pathBuffer lineToPoint:endpoint];
}

-(void)putText:(NSString *)str at:(NSPoint)point
{
  // 
  // Put a line of beautifully rendered Times Roman (AquaTerm default)
  // at the point (x,y), left justified and horisontally (angle 0.0).
  // Also, the client doesnt know the concept of color so we set the
  // linecolor to a fix value. Hence: 
  //
  [aqtConnection addString:str
                   atPoint:point
         withJustification:just
                   atAngle:90.0*orient
          withIndexedColor:colorIndex];
}

-(void)addImageFromFile:(NSString *)filename  bounds:(NSRect)bounds
{
  [aqtConnection addImageFromFile:filename  bounds:bounds];
}

-(void)flushBuffers
{
  if (![pathBuffer isEmpty])
  {
    [pathBuffer setLineWidth:linewidth];
    [aqtConnection addPolyline:pathBuffer withIndexedColor:colorIndex];
    [pathBuffer removeAllPoints];
  }
  if (![filledPathBuffer isEmpty])
  {
    [filledPathBuffer setLineWidth:linewidth];
    [aqtConnection addPolygon:filledPathBuffer withIndexedColor:colorIndex];
    [filledPathBuffer removeAllPoints];
  }  
}

@end /* AQTAdapter */
//
// ----------------------------------------------------------------
// --- FORTRAN example
// ----------------------------------------------------------------
//
void aqt_init__(void)
{
  // The autorelease pool and the adapter object must be initialized,
  // this is the place to do it. But only once!
  //
  if (arpool == NULL)   /* Make sure we don't leak mem by allocating every time */
  {
    arpool = [[NSAutoreleasePool alloc] init];
    adapter = [[AQTAdapter alloc] init];
  }
}

void aqt_open__(int *n)
{
  [adapter openGraph:*n];
}

void aqt_close__(void)
{
  [adapter closeGraph];
}

void aqt_render__(void)
{
  [adapter render];
}

void aqt_title__(char *title)
{
  [adapter setTitle:[NSString stringWithCString:title]];
}

void aqt_use_color__(int *col)
{
  [adapter useColor:*col];
}

void aqt_set_color__(int *col, float *r, float *g, float *b)
{
  [adapter setColor:[NSColor colorWithCalibratedRed:*r green:*g blue:*b alpha:1] forIndex:*col];
}

void aqt_linewidth__(float *width)
{
  [adapter useLinewidth:*width];
}

void aqt_line__(float *x1, float *y1, float *x2, float *y2)
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(*x1, *y1)];
  [path lineToPoint:NSMakePoint(*x2, *y2)];
  [adapter appendPath:path];
}

void aqt_polygon__(float *x, float *y, int *n, bool *isFilled)
{
  int i;
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(x[0], y[0])];
  for (i = 1; i < *n; i++)
  {
    [path lineToPoint:NSMakePoint(x[i], y[i])];
  }
  if (*isFilled)
  {
    [path closePath];
    [adapter appendFilledPath:path];
  }
  else
  {
    [adapter appendPath:path];
  }
}

void aqt_circle__(float *x, float *y, float *radius, bool *isFilled)
{
  NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(*x-(*radius), *y-(*radius), (*radius)*2, (*radius)*2)];
  if (*isFilled)
  {
    [path closePath];
    [adapter appendFilledPath:path];
  }
  else
  {
    [adapter appendPath:path];
  }  
}

void aqt_font__(char *fontname, float *size)
{
  [adapter setFontWithName:[NSString stringWithCString:fontname] size:*size];
}

void aqt_textorient__(int *orient)
{
  [adapter useOrientation:*orient];
}

void aqt_textjust__(int *just)
{
    [adapter useJustification:*just];
}

void aqt_text__(float *x, float *y, const char *str)
{
  [adapter putText:[NSString stringWithCString:str] at:NSMakePoint(*x, *y)];
}

void aqt_imagefromfile__(char *filename, float *x, float *y, float *w, float *h)
{
  [adapter addImageFromFile:[NSString stringWithCString:filename] bounds:NSMakeRect(*x, *y, *w, *h)];
}

void aqt_get_size__(float *x_max, float *y_max)
{
  [adapter updateInfoFromServer];	// Force an update of the termInfo dictionary
  *x_max = [[[adapter termInfo] objectForKey:@"AQTXMax"] floatValue];
  *y_max = [[[adapter termInfo] objectForKey:@"AQTYMax"] floatValue];
}
//
// ----------------------------------------------------------------
// --- End of FORTRAN example
// ----------------------------------------------------------------
//
