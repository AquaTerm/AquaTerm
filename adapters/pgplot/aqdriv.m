#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTProtocol.h"

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}

#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */

#define BUFMAX 50

static NSAutoreleasePool *arpool;   // Objective-C autorelease pool
static id adapter;        		    // Adapter object

// ---- instead of including this as AQTAdapter.h we put it here
// ----------------------------------------------------------------
// --- Start of AQTAdapter interface
// ----------------------------------------------------------------
//
// ----------------------------------------------------------------
// --- AQTAdapter - A class to mediate between C-function calls
// --- and AquaTerm Objective-C remote messages
// ----------------------------------------------------------------
//
@interface AQTAdapter : NSObject
{
  @private
  // --- remote connection
  id aqtConnection;
  // --- state vars
  int currentColor;
  float lineWidth;
  int	polylineBufCount;
  int	polygonBufCount;
  // --- storage objects
  NSBezierPath *polylineBuffer;
  NSBezierPath *polygonBuffer;
  NSBezierPath *polygon;
  NSBitmapImageRep *image;
  NSRect imageBounds;
  float colorlist[256][3];
}
- (id)init;                 // init & dealloc are listed for completeness
- (void)dealloc;
- (id)aqtConnection;        // accessor method
- (BOOL)connectToAquaTerm;	// convenience method
                           //
                           // Obj-C methods implementing the functionality defined in PGPLOT driver
                           //
- (void)openGraph:(int)n size:(NSSize)size;
- (void)closeGraph;
- (void)render;
- (void)flushPolylineBuffer;
- (void)flushPolygonBuffer;
- (void)setColorIndex:(int)colorIndex;
- (void)setLineWidth:(float)newLineWidth;
- (void)lineFromPoint:(NSPoint)startpoint toPoint:(NSPoint)endpoint;
- (void)dotAtPoint:(NSPoint)aPoint;
- (void)fillRect:(NSRect)aRect;
- (void)beginPolygon;
- (void)addPolygonEdgeToPoint:(NSPoint)aPoint;
- (void)fillPolygon;
- (void)beginImageWithSize:(NSSize)imageSize  bounds:(NSRect)theBounds;
- (void)writeImageBytes:(float *)data length:(int)len start:(int)start;
- (void)closeImage;
- (void)setColormapEntry:(int)i red:(float)r green:(float)g blue:(float)b;
- (NSColor *)colormapEntry:(int)i;
@end
// ----------------------------------------------------------------
// --- End of AQTAdapter interface
// ----------------------------------------------------------------

//
// Allow aqdriv to be calleable by FORTRAN using the two commonest
// calling conventions. Both conventions append length arguments for
// each FORTRAN string at the end of the argument list, and convert the
// name to lower-case, but one post-pends an underscore to the function
// name (PG_PPU) while the other doesn't. Note the VMS is handled
// separately below. For other calling conventions you must write a
// C wrapper routine to call aqdriv() or aqdriv_().
//
// FIXME: what is appropriate on OS X?
//
#ifdef PG_PPU
#define AQDRIV aqdriv_
#else
#define AQDRIV aqdriv
#endif


static int currentPlot = 0;

// ----------------------------------------------------------------
// --- Start of PGPLOT function aqdriv()
// ----------------------------------------------------------------
void AQDRIV(int *ifunc, float rbuf[], int *nbuf, char *chr, int *lchr, int len)
{
  static int edgeCount = 0; // Keep track of polygon sides
  static int pixPtr = 0;
  int i;
  //
  // Branch on the specified PGPLOT opcode.
  //
  switch(*ifunc)
  {
    /* --- IFUNC=1, Return device name ---------------------------------------*/
    case 1:
    {
      char *dev_name = "AQT (AqauTerm.app under Mac OS X)";
      LOG(@"IFUNC=1, Return device name");
      strncpy(chr, dev_name, len);
      *lchr = strlen(dev_name);
      for(i = *lchr; i < len; i++)
        chr[i] = ' ';
    };
      break;


      //--- IFUNC=2, Return physical min and max for plot device, and range of color indices -----------------------------------------
    case 2:
      LOG(@"IFUNC=2, Return physical min and max for plot device, and range of color indices");
      rbuf[0] = 0.0;
      rbuf[1] = -1.0;     // Report no effective max plot width
      rbuf[2] = 0.0;
      rbuf[3] = -1.0;     // Report no effective max plot height
      rbuf[4] = 0.0;
      rbuf[5] = 255.0;    // Return a fixed number for now
      *nbuf = 6;
      break;

      //--- IFUNC=3, Return device resolution ---------------------------------

    case 3:
      LOG(@"IFUNC=3, Return device resolution");
      rbuf[0] = 72.0;     // Device x-resolution in pixels/inch
      rbuf[1] = 72.0;     // Device y-resolution in pixels/inch
      rbuf[2] = 1.0;		// Device coordinates per pixel
      *nbuf = 3;
      break;

      //--- IFUNC=4, Return misc device info ----------------------------------

    case 4:
      LOG(@"IFUNC=4, Return misc device info");
      chr[0] = 'I'; // Interactive device
      chr[1] = 'N'; // Cursor is not available
      chr[2] = 'N'; // No dashed lines
      chr[3] = 'A'; // Area fill available
      chr[4] = 'T'; // Thick lines
      chr[5] = 'R'; // Rectangle fill available
      chr[6] = 'Q'; // Has image primitives (opcode 26)
      chr[7] = 'N'; // Don't prompt on pgend
      chr[8] = 'Y'; // Can return color representation
      chr[9] = 'N'; // Not used
      chr[10]= 'N'; // Area-scroll available
      *lchr = 11;
      break;

      //--- IFUNC=5, Return default file name ---------------------------------

    case 5:
    LOG(@"IFUNC=5, Return default file name");
      chr[0] = '\0';  // Default name is ""
      *lchr = 0;
      break;

      //--- IFUNC=6, Return default physical size of plot ---------------------

    case 6:
    LOG(@"IFUNC=6, Return default physical size of plot");
      rbuf[0] = 0.0;      // default x-coordinate of bottom left corner (must be zero)
      rbuf[1] = 842.0;    // default x-coordinate of top right corner
      rbuf[2] = 0.0;      // default y-coordinate of bottom left corner (must be zero)
      rbuf[3] = 595.0;    // default y-coordinate of top right corner
      *nbuf = 4;
      break;

      //--- IFUNC=7, Return misc defaults -------------------------------------

    case 7:
      LOG(@"IFUNC=7, Return misc defaults");
      rbuf[0] = 1.0;
      *nbuf = 1;
      break;

      //--- IFUNC=8, Select plot ----------------------------------------------

    case 8:
      LOG(@"IFUNC=8, Select plot");
      currentPlot = (int)rbuf[0];
      break;

      //--- IFUNC=9, Open workstation -----------------------------------------

    case 9:
      LOG(@"IFUNC=9, Open workstation");
      //
      // Assign the returned device unit number and success indicator.
      // Assume failure to open until the workstation is open.
      //
      rbuf[0] = rbuf[1] = 0.0;
      *nbuf = 2;
      //
      if (arpool == NULL)   /* Make sure we don't leak mem by allocating every time */
      {
        arpool = [[NSAutoreleasePool alloc] init];
        adapter = [[AQTAdapter alloc] init];
      }
        if(adapter)
        {
          rbuf[0] = 1.0; // The number used to select this device
          rbuf[1] = 1.0;
          *nbuf = 2;
        }
        break;

      //--- IFUNC=10, Close workstation ---------------------------------------

    case 10:
      LOG(@"FUNC=10, Close workstation");
      break;

      //--- IFUNC=11, Begin picture -------------------------------------------

    case 11:
      LOG(@"IFUNC=11, Begin picture");
      [adapter openGraph:currentPlot size:NSMakeSize(rbuf[0], rbuf[1])];
      break;

      //--- IFUNC=12, Draw line -----------------------------------------------

    case 12:
      LOG(@"IFUNC=12, Draw line");
      [adapter lineFromPoint:NSMakePoint(rbuf[0], rbuf[1]) toPoint:NSMakePoint(rbuf[2], rbuf[3])];
      break;

      //--- IFUNC=13, Draw dot ------------------------------------------------

    case 13:
      LOG(@"IFUNC=13, Draw dot");
      [adapter dotAtPoint:NSMakePoint(rbuf[0], rbuf[1])];
      break;

      //--- IFUNC=14, End picture ---------------------------------------------

    case 14:
      LOG(@"IFUNC=14, End picture");
      if (rbuf[0] != 0.0)
      {
        // clear screen
      }
        [adapter closeGraph];
      break;

      //--- IFUNC=15, Select color index --------------------------------------

    case 15:
      LOG(@"IFUNC=15, Select color index %d", (int)rbuf[0]);
      [adapter setColorIndex:rbuf[0]];
      break;

      //--- IFUNC=16, Flush buffer. -------------------------------------------

    case 16:
      LOG(@"IFUNC=16, Flush buffer");
      // FIXME: this could be devastating for complex plots, sanity check needed!
      [adapter render];
      break;

      //--- IFUNC=17, Read cursor. --------------------------------------------

    case 17:
      LOG(@"IFUNC=17, Read cursor");
      break;

      //--- IFUNC=18, Erase alpha screen. -------------------------------------
      // (Not implemented: no alpha screen)
    case 18:
      LOG(@"18");
      break;

      //--- IFUNC=19, Set line style. -----------------------------------------
      // (Not implemented: should not be called)
    case 19:
      LOG(@"19");
      break;

      //--- IFUNC=20, Polygon fill. -------------------------------------------

    case 20:
      //
      // kludgy, improve later
      //
      LOG(@"IFUNC=20, Polygon fill");
      if (edgeCount)
      {
        // add edges to polygon
        [adapter addPolygonEdgeToPoint:NSMakePoint(rbuf[0], rbuf[1])];
        edgeCount--;
        if (!edgeCount)
        {
          [adapter fillPolygon];
        }
      }
        else
        {
          edgeCount = rbuf[0];
          [adapter beginPolygon];
        }
        break;

      //--- IFUNC=21, Set color representation. -------------------------------

    case 21:
      LOG(@"IFUNC=21, Set color representation for index %d", (int)rbuf[0]);
      [adapter setColormapEntry:(int)rbuf[0] red:rbuf[1] green:rbuf[2] blue:rbuf[3]];
      break;

      //--- IFUNC=22, Set line width. -----------------------------------------

    case 22:
      LOG(@"IFUNC=22, Set line width");
      [adapter setLineWidth:rbuf[0]];    // rbuf[0] is in units of 0.005 inch
      break;

      //--- IFUNC=23, Escape --------------------------------------------------
      // (Not implemented: ignored)
    case 23:
      LOG(@"23");
      break;

      //--- IFUNC=24, Rectangle Fill. -----------------------------------------

    case 24:
      LOG(@"IFUNC=24, Rectangle Fill");
      [adapter fillRect:NSMakeRect(rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1])];
      break;

      //--- IFUNC=25, ---------------------------------------------------------
      // (Not implemented: ignored)
    case 25:
      LOG(@"25");
      break;

      //--- IFUNC=26, Line of pixels ------------------------------------------

    case 26:
      LOG(@"IFUNC=26, Line of pixels");
      switch((int)rbuf[0])
      {
        case 0:
          LOG(@"Start. w=%f, h=%f", rbuf[1], rbuf[2]);
          LOG(@"Bounds %f, %f, %f, %f", rbuf[3], rbuf[5], rbuf[4]-rbuf[3], rbuf[6]-rbuf[5]);
          [adapter beginImageWithSize:NSMakeSize(rbuf[1], rbuf[2])
                               bounds:NSMakeRect(rbuf[3], rbuf[5], rbuf[4]-rbuf[3], rbuf[6]-rbuf[5])];
          break;
        case -1:
          LOG(@"End.");
          [adapter closeImage];
          pixPtr = 0;
          break;
        default:
          LOG(@"Pixels... n=%f data=%f, %f, %f, ...", rbuf[0], rbuf[1], rbuf[2], rbuf[3]);
          [adapter writeImageBytes:&rbuf[1] length:(int)rbuf[0] start:pixPtr];
          pixPtr += (int)rbuf[0];
          break;
      }
        break;

      //--- IFUNC=27, World-coordinate scaling --------------------------------

    case 27:
      LOG(@"IFUNC=27, World-coordinate scaling");
      break;

      //--- IFUNC=28, Draw marker ---------------------------------------------
    case 28:
      LOG(@"IFUNC=28, Draw marker");
      break;

      //--- IFUNC=29, Query color representation ------------------------------
    case 29:
    {
      NSColor *color = [adapter colormapEntry:(int)rbuf[0]];
      NSLog(@"IFUNC=29, Query color representation for index %d", (int)rbuf[0]);
      rbuf[1] = [color redComponent];
      rbuf[2] = [color greenComponent];
      rbuf[3] = [color blueComponent];
      *nbuf = 4;
    }
      break;

      //--- IFUNC=30, Scroll rectangle ----------------------------------------
    case 30:
      LOG(@"IFUNC=30, Scroll rectangle");
      break;

      //--- IFUNC=?, ----------------------------------------------------------

    default:
      LOG(@"xxx");
      NSLog(@"/AQT: Unexpected opcode=%d in stub driver.", *ifunc);
      *nbuf = -1;
      break;
  };
  return;
}
// ----------------------------------------------------------------
// --- End of PGPLOT function aqdriv()
// ----------------------------------------------------------------

//
// The class NSBezierPath doesn't implement replacementObjectForPortCoder so
// we add that behaviour as a category for NSBezierPath
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

// ----------------------------------------------------------------
// --- Start of AQTAdapter class
// ----------------------------------------------------------------
@implementation AQTAdapter
- (id)init
{
  int i;
  if (self = [super init])
  {
    // Init instance variables
    polygon = [[NSBezierPath bezierPath] retain];
    polylineBuffer = [[NSBezierPath bezierPath] retain];
    polygonBuffer = [[NSBezierPath bezierPath] retain];

    for (i=0;i<256;i++)
    {
      colorlist[i][0]=((float)i)/255.0;
      colorlist[i][1]=0.0;
      colorlist[i][2]=0.0;
    }
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
       // set default colormap [0-15]
      [self setColormapEntry:0 red:1.0 green:1.0 blue:1.0];
      [self setColormapEntry:1 red:0.0 green:0.0 blue:0.0];
      [self setColormapEntry:2 red:1.0 green:0.0 blue:0.0];
      [self setColormapEntry:3 red:0.0 green:1.0 blue:0.0];
      [self setColormapEntry:4 red:0.0 green:0.0 blue:1.0];
      [self setColormapEntry:5 red:0.0 green:1.0 blue:1.0];
      [self setColormapEntry:6 red:1.0 green:0.0 blue:1.0];
      [self setColormapEntry:7 red:1.0 green:1.0 blue:0.0];
      [self setColormapEntry:8 red:1.0 green:0.5 blue:0.0];
      [self setColormapEntry:9 red:0.5 green:1.0 blue:0.0];
      [self setColormapEntry:10 red:0.0 green:1.0 blue:0.5];
      [self setColormapEntry:11 red:0.0 green:0.5 blue:1.0];
      [self setColormapEntry:12 red:0.5 green:0.0 blue:1.0];
      [self setColormapEntry:13 red:1.0 green:0.0 blue:0.5];
      [self setColormapEntry:14 red:0.33 green:0.33 blue:0.33];
      [self setColormapEntry:15 red:0.67 green:0.67 blue:0.67];
    }
  }
  return self;
}

- (void)dealloc
{
  [aqtConnection release];
  [polygon release];
  [polylineBuffer release];
  [polygonBuffer release];
  [super dealloc];
}

- (id)aqtConnection
{
  return aqtConnection;
}

- (BOOL)connectToAquaTerm
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
  LOG(@"didConnect=%d",didConnect);
  return didConnect;
}
//
// Adapter methods, this is where the translation takes place!
//
// The methods known by AquaTerm are defined in AQTProtocol.h
// and the function calls known to the client are defined in C_API.h
//
- (void)setColorIndex:(int)colorIndex;
{
  //
  // This requires flushing of any buffers
  //
  [self flushPolygonBuffer];
  [self flushPolylineBuffer];
  currentColor = (colorIndex == 0)?-4:colorIndex-1;
}

- (void)setLineWidth:(float)newLineWidth
{
  //
  // This requires flushing of the polyline buffer
  //
  [self flushPolylineBuffer];
  newLineWidth = newLineWidth*0.005*72;
  // Limit thinnest line
  lineWidth=newLineWidth<.5?.5:newLineWidth;
}

- (void)openGraph:(int)n size:(NSSize)size
{
  //
  // Select a "model"
  //
  [aqtConnection openModel:n size:size];
}

- (void)closeGraph
{
  //
  // Draw (render) the currently selected model
  // This requires flushing of any buffers
  //
  [self flushPolygonBuffer];
  [self flushPolylineBuffer];
  [aqtConnection closeModel];
}

- (void)render
{
  //
  // Draw (render) the currently selected model
  // but leave it open for further drawing
  // This requires flushing of any buffers
  //
  [self flushPolygonBuffer];
  [self flushPolylineBuffer];
  [aqtConnection render];
}

- (void)flushPolylineBuffer
{
  if (![polylineBuffer isEmpty])
  {
    [polylineBuffer setLineWidth:lineWidth];
    [aqtConnection addPolyline:polylineBuffer withIndexedColor:currentColor];
    [polylineBuffer removeAllPoints];
    polylineBufCount = 0;
  }
}

- (void)flushPolygonBuffer
{
  if (![polygonBuffer isEmpty])
  {
    // FIXME: setting linewidth here???? cf flushPolylineBuffer
    [aqtConnection addPolygon:polygonBuffer withIndexedColor:currentColor];
    [polygonBuffer removeAllPoints];
    polygonBufCount = 0;
  }
}

- (void)lineFromPoint:(NSPoint)startpoint toPoint:(NSPoint)endpoint
{
  [polylineBuffer moveToPoint:startpoint];
  [polylineBuffer lineToPoint:endpoint];
  polylineBufCount += 1;
  if (polylineBufCount > BUFMAX)
  {
    [self flushPolylineBuffer];
  }
}

- (void)dotAtPoint:(NSPoint)aPoint
{
  NSRect cRect;
  NSBezierPath *thePath;

  cRect.origin = NSMakePoint(aPoint.x - lineWidth, aPoint.y - lineWidth);
  cRect.size = NSMakeSize(2*lineWidth, 2*lineWidth);
  thePath = [NSBezierPath bezierPathWithOvalInRect:cRect];
  // [aqtConnection addPolygon:thePath withIndexedColor:currentColor];
  [polygonBuffer appendBezierPath:thePath];
  polygonBufCount +=1;
  if (polygonBufCount > BUFMAX)
  {
    [self flushPolygonBuffer];
  }
}

- (void) fillRect:(NSRect)aRect
{
  NSBezierPath *thePath = [NSBezierPath bezierPathWithRect:aRect];
  //
  // close up the path and send the polygon to AquaTerm
  //
  [thePath closePath];
  // [aqtConnection addPolygon:thePath withIndexedColor:currentColor];
  [polygonBuffer appendBezierPath:thePath];
  polygonBufCount +=4;
  if (polygonBufCount > BUFMAX)
  {
    [self flushPolygonBuffer];
  }  
}
//
// --- PGPLOT uses a sequence of calls to build a polygon
//
- (void)beginPolygon
{
  [polygon removeAllPoints];
}

- (void)addPolygonEdgeToPoint:(NSPoint)aPoint
{
  if ([polygon isEmpty])
  {
    [polygon moveToPoint:aPoint];
  }
  else
  {
    [polygon lineToPoint:aPoint];
  }
  polygonBufCount +=1;
}

- (void)fillPolygon
{
  [polygon closePath];
  // [aqtConnection addPolygon:polygon withIndexedColor:currentColor];
  [polygonBuffer appendBezierPath:polygon];
  if (polygonBufCount > BUFMAX)
  {
    [self flushPolygonBuffer];
  }  
}
//
// --- PGPLOT uses a sequence of calls to build an image
//
- (void)beginImageWithSize:(NSSize)imageSize bounds:(NSRect)theBounds
{
  image = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                  pixelsWide:imageSize.width
                                                  pixelsHigh:imageSize.height
                                               bitsPerSample:8
                                             samplesPerPixel:3
                                                    hasAlpha:NO
                                                    isPlanar:YES
                                              colorSpaceName:NSCalibratedRGBColorSpace
                                                 bytesPerRow:0
                                                bitsPerPixel:0];
  imageBounds = theBounds;
}

- (void)writeImageBytes:(float *)data length:(int)len start:(int)start
{
  int i;
  unsigned char *dataPlanes[5];
  unsigned char *imageData;

  [image getBitmapDataPlanes:dataPlanes];
  for(i=0;i<len;i++)
  {
    *(dataPlanes[0]+start+i) = (unsigned char)(255*colorlist[(int)data[i]][0]);
    *(dataPlanes[1]+start+i) = (unsigned char)(255*colorlist[(int)data[i]][1]);
    *(dataPlanes[2]+start+i) = (unsigned char)(255*colorlist[(int)data[i]][2]);
  }
}

- (void)closeImage
{
  [aqtConnection addBitmap:[image TIFFRepresentation] size:NSMakeSize([image pixelsWide],[image pixelsHigh]) bounds:imageBounds];
  [image release];
}
//
// FIXME: For now, we keep a local colormap. AQT does _not_ restore colormap for subsequent plots
// FIXME: this too would benefit from being buffered
//
-(void)setColormapEntry:(int)i red:(float)r green:(float)g blue:(float)b
{
  NSColor *tempColor = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0];
  [aqtConnection setColor:tempColor forIndex:(i == 0)?-4:i-1];
  // Set r,g and b values of the i:th color in local colormap
  colorlist[i][0]=r;
  colorlist[i][1]=g;
  colorlist[i][2]=b;

}
-(NSColor *)colormapEntry:(int)i
{
  // return an NSColor object with r,g and b values of the i:th color in local colormap
  return [NSColor colorWithCalibratedRed:colorlist[i][0] green:colorlist[i][1] blue:colorlist[i][2] alpha:1.0];
}
@end
// ----------------------------------------------------------------
// --- End of AQTAdapter class
// ----------------------------------------------------------------
