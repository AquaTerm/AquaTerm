#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}

#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */

#define BUFMAX 50

typedef struct {
  float r;
  float g;
  float b;
} PGPColor;

static NSAutoreleasePool *arpool;   // Objective-C autorelease pool
static id adapter;        		    // Adapter object

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

// Testing the use of a callback function to handle errors in the server
void errorHandler(NSString *msg)
{
  NSLog(msg);
  //NSLog(@"rc = %d", [adapter retainCount]);
  [adapter autorelease]; // add adapter to the AutoReleasePool
  adapter = nil;
}

void initAdapter(void)
{
  // Either first time or an error has occurred
  [arpool release]; // clean
  arpool = [[NSAutoreleasePool alloc] init];
  adapter = [[AQTAdapter alloc] init];
  // [adapter setErrorHandler:errMsg];
}

static int currentPlot = 0;

// ----------------------------------------------------------------
// --- Start of PGPLOT function aqdriv()
// ----------------------------------------------------------------
void AQDRIV(int *ifunc, float rbuf[], int *nbuf, char *chr, int *lchr, int len)
{
  //static int edgeCount = 0; // Keep track of polygon sides
  //static int pixPtr = 0;
  //int i;
  static int tmpCol=11;
  static PGPColor cm[256];
  //
  // Branch on the specified PGPLOT opcode.
  //
  switch(*ifunc)
  {
    /* --- IFUNC=1, Return device name ---------------------------------------*/
    case 1:
    {
      int i;
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
      chr[1] = 'C'; // Cursor is not available
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
      if (!adapter)
      {
        initAdapter();
      }
        rbuf[0] = 1.0; // The number used to select this device
      rbuf[1] = 1.0;
      *nbuf = 2;
      break;

      //--- IFUNC=10, Close workstation ---------------------------------------

    case 10:
      LOG(@"FUNC=10, Close workstation");
      [adapter autorelease];
      adapter = nil;
      [arpool release];
      arpool = nil;
      break;

      //--- IFUNC=11, Begin picture -------------------------------------------

    case 11:
    {
      int i;
      LOG(@"IFUNC=11, Begin picture");
      if (!adapter)
      {
        initAdapter();
      }
      //[adapter openGraph:currentPlot size:NSMakeSize(rbuf[0], rbuf[1])];
      [adapter openPlotIndex:currentPlot size:NSMakeSize(rbuf[0], rbuf[1]) title:nil];
      cm[0].r = 1.0; cm[0].g = 1.0; cm[0].b = 1.0;
      cm[1].r = 0.0; cm[1].g = 0.0; cm[1].b = 0.0;
      cm[2].r = 1.0; cm[2].g = 0.0; cm[2].b = 0.0;
      cm[3].r = 0.0; cm[3].g = 1.0; cm[3].b = 0.0;
      cm[4].r = 0.0; cm[4].g = 0.0; cm[4].b = 1.0;
      cm[5].r = 0.0; cm[5].g = 1.0; cm[5].b = 1.0;
      cm[6].r = 1.0; cm[6].g = 0.0; cm[6].b = 1.0;
      cm[7].r = 1.0; cm[7].g = 1.0; cm[7].b = 0.0;
      /*
       [self setColormapEntry:8 red:1.0 green:0.5 blue:0.0];
       [self setColormapEntry:9 red:0.5 green:1.0 blue:0.0];
       [self setColormapEntry:10 red:0.0 green:1.0 blue:0.5];
       [self setColormapEntry:11 red:0.0 green:0.5 blue:1.0];
       [self setColormapEntry:12 red:0.5 green:0.0 blue:1.0];
       [self setColormapEntry:13 red:1.0 green:0.0 blue:0.5];
       [self setColormapEntry:14 red:0.33 green:0.33 blue:0.33];
       [self setColormapEntry:15 red:0.67 green:0.67 blue:0.67];
       */
      /*
       for (i=2;i<255;i++)
       {
         cm[i].r=((float)i)/255.0;
         cm[i].g=0.0;
         cm[i].b=0.0;
       }
       */
    }
      break;

      //--- IFUNC=12, Draw line -----------------------------------------------

    case 12:
    {
      // FIXME: reduce amount of objects by coalescing lines starting at last endpoint
      static NSPoint lastPoint;
      NSPoint startPoint = NSMakePoint(rbuf[0], rbuf[1]);
      NSPoint endPoint = NSMakePoint(rbuf[2], rbuf[3]);

      LOG(@"IFUNC=12, Draw line");
      if (!NSEqualPoints(lastPoint, startPoint))
      {
        [adapter addLineAtPoint:startPoint];
      }
      [adapter appendLineToPoint:endPoint];
      lastPoint = endPoint;
    }
      break;

      //--- IFUNC=13, Draw dot ------------------------------------------------

    case 13:
      LOG(@"IFUNC=13, Draw dot");
      //[adapter dotAtPoint:NSMakePoint(rbuf[0], rbuf[1])];
      break;

      //--- IFUNC=14, End picture ---------------------------------------------

    case 14:
      LOG(@"IFUNC=14, End picture");
      if (rbuf[0] != 0.0)
      {
        // clear screen
      }
        [adapter closePlot];
      break;

      //--- IFUNC=15, Select color index --------------------------------------

    case 15:
      LOG(@"IFUNC=15, Select color index %d", (int)rbuf[0]);
      tmpCol = (int)rbuf[0];
      //[adapter setColorIndex:rbuf[0]];
      [adapter setColorRed:cm[tmpCol].r green:cm[tmpCol].g blue:cm[tmpCol].b];
      break;

      //--- IFUNC=16, Flush buffer. -------------------------------------------

    case 16:
      LOG(@"IFUNC=16, Flush buffer");
      // FIXME: this could be devastating for complex plots, sanity check needed!
      // FIXME: use a timer to "coalesce" actual rendering calls, just make sure graphics buffers are flushed
      [adapter render];
      break;

      //--- IFUNC=17, Read cursor. --------------------------------------------

    case 17:
    {
      NSPoint pos;
      char key;
      LOG(@"IFUNC=17, Read cursor");
      /*
       Parameters passed to handler:
       RBUF(1): initial x position of cursor.
       RBUF(2): initial y position of cursor.
       RBUF(3): x position of reference point.
       RBUF(4): y position of reference point.
       RBUF(5): mode = 0 (no feedback), 1 (rubber band), 2 (rubber rectangle), 3 (vertical range),
       4 (horizontal range). 5 (horizontal line), 6 (vertical line), 7 (cross-hair).

       Parameters returned by handler:
       RBUF(1): x position of cursor.
       RBUF(2): y position of cursor.
       CHR(1:1): character typed by user.
       */

      key = [adapter getMouseInput:&pos options:0];
      NSLog(@"Key %c at %@", key, NSStringFromPoint(pos));
      rbuf[0] = pos.x;
      rbuf[1] = pos.y;
      if (pos.x<10)
        chr[0] = 'X';
      else
        chr[0] = key;

    }
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
    {
      static NSPoint vertices[64];
      static int vCount = 0;
      static int vMax = 0;
      LOG(@"IFUNC=20, Polygon fill");

      if (vMax == 0)
      {
        // First call
        vMax = (int)rbuf[0];
        vCount = 0;
        if (vMax > 64)
          NSLog(@"**** Too many vertices in polygon (%d)", vMax);
      }
      else
      {
        vertices[MIN(vCount, 63)] = NSMakePoint(rbuf[0], rbuf[1]);
        vCount++;
        if (vCount == vMax)
        {
          [adapter addPolygonWithPoints:vertices pointCount:MIN(vMax, 64)];
          vMax = 0;
        }
      }
    }
    break;

      //--- IFUNC=21, Set color representation. -------------------------------

    case 21:
    {
      int index = (int)rbuf[0];
      LOG(@"IFUNC=21, Set color representation for index %d", (int)rbuf[0]);
      // [adapter setColormapEntry:(int)rbuf[0] red:rbuf[1] green:rbuf[2] blue:rbuf[3]];
      if (index < 256)
      {
        cm[index].r = rbuf[1];
        cm[index].g = rbuf[2];
        cm[index].b = rbuf[3];
      }
    }
      break;

      //--- IFUNC=22, Set line width. -----------------------------------------

    case 22:
      LOG(@"IFUNC=22, Set line width");
      [adapter setLinewidth:(72.0*rbuf[0]*0.005)];    // rbuf[0] is in units of 0.005 inch
      break;

      //--- IFUNC=23, Escape --------------------------------------------------
      // (Not implemented: ignored)
    case 23:
      LOG(@"23");
      break;

      //--- IFUNC=24, Rectangle Fill. -----------------------------------------

    case 24: // FIXME: this is used for erasing, with color 0.
    {
      NSPoint corners[4];
      LOG(@"IFUNC=24, Rectangle Fill");
      //[adapter fillRect:NSMakeRect(rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1])];
      //NSLog(@"Filling Rect(%f, %f, %f, %f) with indexed color %d",rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1],tmpCol);
      if (tmpCol == 0)
      {
        // First, remove objects _completely_ hidden behind rectangles drawn in background color...
        NSLog(@"Erasing Rect(%f, %f, %f, %f)",rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1]);
        [adapter eraseRect:NSMakeRect(rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1])];
      }
      corners[0]=NSMakePoint(rbuf[0], rbuf[1]);
      corners[1]=NSMakePoint(rbuf[2], rbuf[1]);
      corners[2]=NSMakePoint(rbuf[2], rbuf[3]);
      corners[3]=NSMakePoint(rbuf[0], rbuf[3]);
      [adapter addPolygonWithPoints:corners pointCount:4];
    }
      break;

      //--- IFUNC=25, ---------------------------------------------------------
      // (Not implemented: ignored)
    case 25:
      LOG(@"25");
      break;

      //--- IFUNC=26, Line of pixels ------------------------------------------
    case 26:
    {
      static BOOL processingBitmap = NO;
      static unsigned char *pixPtr;
      static unsigned char *dataPtr;
      static int pixCount;
      static int maxPixCount;
      static NSSize bitmapSize;
      static NSRect imageBounds;

      switch((int)rbuf[0])
      {
        case 0:
          // Set up memory storage and basic parameters
          processingBitmap = YES;
          bitmapSize = NSMakeSize((int)rbuf[1], (int)rbuf[2]);
          imageBounds = NSMakeRect(rbuf[3], rbuf[5], rbuf[4]-rbuf[3], rbuf[6]-rbuf[5]);
          NSLog(@"bitmapsize: %@\nimageBounds: %@", NSStringFromSize(bitmapSize), NSStringFromRect(imageBounds));
          NSLog(@"Matrix: %f, %f, %f, %f, %f, %f", rbuf[7], rbuf[8], rbuf[9], rbuf[10], rbuf[11], rbuf[12]);
          pixCount = 0;
          maxPixCount = 3*bitmapSize.width*bitmapSize.height*sizeof(unsigned char);
          pixPtr = (unsigned char *)malloc(maxPixCount);
          dataPtr = pixPtr;
          break;
        case -1:
          // End of data indicator
          LOG(@"End.");
          [adapter addImageWithBitmap:pixPtr size:bitmapSize bounds:imageBounds];
          processingBitmap = NO;
          free(pixPtr);
          break;
        default:
        {
          // Write 3*n pixels to buffer
          int i;
          int n = (int)rbuf[0];
          // NSLog(@"Pixels... n=%f data=%f, %f, %f, ...", rbuf[0], rbuf[1], rbuf[2], rbuf[3]);
          for (i = 1; i<=n;i++)
          {
            unsigned char red = (unsigned char)(255*cm[(int)rbuf[i]].r);
            unsigned char green = (unsigned char)(255*cm[(int)rbuf[i]].g);
            unsigned char blue = (unsigned char)(255*cm[(int)rbuf[i]].b);

            *dataPtr = red;
            dataPtr++;
            *dataPtr = green;
            dataPtr++;
            *dataPtr = blue;
            dataPtr++;
            //NSLog(@"pixCount: %d", dataPtr-pixPtr);
            //NSLog(@"Last rgb = (%u, %u, %u)", red, green, blue);
          }
        }
          break;
      }


      LOG(@"IFUNC=26, Line of pixels");
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
      int index = (int)rbuf[0];
      // NSColor *color = [adapter colormapEntry:(int)rbuf[0]];
      // NSLog(@"IFUNC=29, Query color representation for index %d", (int)rbuf[0]);
      rbuf[1] = cm[index].r; //[color redComponent];
      rbuf[2] = cm[index].g;//[color greenComponent];
      rbuf[3] = cm[index].b;//[color blueComponent];
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