#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}

#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif	/* LOGGING */

static NSAutoreleasePool *arpool;    // Objective-C autorelease pool
static id adapter;                   // Adapter object

//
// Allow aqdriv to be calleable by FORTRAN using the two commonest
// calling conventions. Both conventions append length arguments for
// each FORTRAN string at the end of the argument list, and convert the
// name to lower-case, but one post-pends an underscore to the function
// name (PG_PPU) while the other doesn't. Note the VMS is handled
// separately below. For other calling conventions you must write a
// C wrapper routine to call aqdriv() or aqdriv_().
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
  [adapter autorelease]; // add adapter to the AutoReleasePool
  adapter = nil;
}


void initAdapter(void)
{
  // Either first time or an error has occurred
  [arpool release]; // clean
  arpool = [[NSAutoreleasePool alloc] init];
  adapter = [[AQTAdapter alloc] init];
  [adapter setErrorHandler:errorHandler];
}

static int currentDevice = 0;
static int deviceCount = 0;

// ----------------------------------------------------------------
// --- Start of PGPLOT function aqdriv()
// ----------------------------------------------------------------
void AQDRIV(int *ifunc, float rbuf[], int *nbuf, char *chr, int *lchr, int len)
{
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
      rbuf[2] = 1.0;	  // Device coordinates per pixel
      *nbuf = 3;
      break;

      //--- IFUNC=4, Return misc device info ----------------------------------

    case 4:
      LOG(@"IFUNC=4, Return misc device info");
      chr[0] = 'I'; // Interactive device
      chr[1] = 'C'; // Cursor is available
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
      LOG(@"IFUNC=8, Select plot: [%d %d]", (int)rbuf[0] /* plot id */, (int)rbuf[1] /* device id */);
      currentDevice = (int)rbuf[1];
      [adapter selectPlotWithIndex:currentDevice];
      break;

      //--- IFUNC=9, Open workstation -----------------------------------------

    case 9:
      LOG(@"IFUNC=9, Open workstation Append:%@", (int)rbuf[2]?@"YES":@"NO" );
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
      deviceCount++;
      currentDevice = deviceCount;
      [adapter openPlotWithIndex:currentDevice];
      
      rbuf[0] = (float)currentDevice; // The number used to select this device by IFUNC=8 (Select plot)
      rbuf[1] = 1.0;
      *nbuf = 2;
      break;

      //--- IFUNC=10, Close workstation ---------------------------------------

    case 10:
      LOG(@"FUNC=10, Close workstation (currentDevice = %d)", currentDevice );
      [adapter closePlot];
      break;

      //--- IFUNC=11, Begin picture -------------------------------------------

    case 11:
    {
      int i;
      LOG(@"IFUNC=11, Begin picture");
      [adapter clearPlot];
      [adapter setColormapEntry:0 red:0.0 green:0.0 blue:0.0]; // Background color
      [adapter setColormapEntry:1 red:1.0 green:1.0 blue:1.0]; 
      [adapter setColormapEntry:2 red:1.0 green:0.0 blue:0.0];
      [adapter setColormapEntry:3 red:0.0 green:1.0 blue:0.0];
      [adapter setColormapEntry:4 red:0.0 green:0.0 blue:1.0];
      [adapter setColormapEntry:5 red:0.0 green:1.0 blue:1.0];
      [adapter setColormapEntry:6 red:1.0 green:0.0 blue:1.0];
      [adapter setColormapEntry:7 red:1.0 green:1.0 blue:0.0];
      [adapter setColormapEntry:8 red:1.0 green:0.5 blue:0.0];
      [adapter setColormapEntry:9 red:0.5 green:1.0 blue:0.0];
      [adapter setColormapEntry:10 red:0.0 green:1.0 blue:0.5];
      [adapter setColormapEntry:11 red:0.0 green:0.5 blue:1.0];
      [adapter setColormapEntry:12 red:0.5 green:0.0 blue:1.0];
      [adapter setColormapEntry:13 red:1.0 green:0.0 blue:0.5];
      [adapter setColormapEntry:14 red:0.33 green:0.33 blue:0.33];
      [adapter setColormapEntry:15 red:0.67 green:0.67 blue:0.67];

      [adapter takeBackgroundColorFromColormapEntry:0];
      [adapter setLineCapStyle:AQTRoundLineCapStyle];
      [adapter setPlotSize:NSMakeSize(rbuf[0], rbuf[1])];
      [adapter setPlotTitle:[NSString stringWithFormat:@"Device %d", currentDevice]];
    }
      break;

      //--- IFUNC=12, Draw line -----------------------------------------------

    case 12:
      LOG(@"IFUNC=12, Draw line");
      [adapter moveToPoint:NSMakePoint(rbuf[0], rbuf[1])];
      [adapter addLineToPoint:NSMakePoint(rbuf[2], rbuf[3])];
      break;

      //--- IFUNC=13, Draw dot ------------------------------------------------

    case 13:
      LOG(@"IFUNC=13, Draw dot"); // FIXME (set buttstyle explicitly?)
      [adapter moveToPoint:NSMakePoint(rbuf[0], rbuf[1])];
      [adapter addLineToPoint:NSMakePoint(rbuf[0]+1.0, rbuf[1])];
      break;

      //--- IFUNC=14, End picture ---------------------------------------------

    case 14:
       LOG(@"IFUNC=14, End picture (%f)", rbuf[0]);
       if (0 != (int)rbuf[0])
       {
          // Clear screen, using (ii) below
          // Either i) specify 'V' for device capab. 7 and _close_ win after prompt
          // or ii) specify 'N' for device capab. 7 and leave plot window open and visible, no prompt
          //
          // [adapter clearPlot];
          // [adapter closePlot]
       }
       break;

      //--- IFUNC=15, Select color index --------------------------------------

    case 15:
      LOG(@"IFUNC=15, Select color index %d", (int)rbuf[0]);
      [adapter takeColorFromColormapEntry:(int)rbuf[0]];
      break;

      //--- IFUNC=16, Flush buffer. -------------------------------------------

    case 16:
      LOG(@"IFUNC=16, Flush buffer");
      [adapter renderPlot];
      break;

      //--- IFUNC=17, Read cursor. --------------------------------------------

    case 17:
    {
       BOOL isRunning;
       NSArray *eventData;
       NSString *event;
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

       event = [adapter waitNextEvent];
       // Dissect the event here...
       eventData = [event componentsSeparatedByString:@":"];
       switch ([[eventData objectAtIndex:0] intValue])
       {
          case 0:
             break;
          case 1: // Mouse down
             pos = NSPointFromString([eventData objectAtIndex:1]);
             key = ([[eventData objectAtIndex:2] intValue]==1)?'A':'X';
             break;
          case 2: // Key down
             pos = NSPointFromString([eventData objectAtIndex:1]);
             key = [[eventData objectAtIndex:2] lossyCString][0];
             break;
          default:
             NSLog(@"Unknown event, discarding.");
       }
       
       rbuf[0] = pos.x;
       rbuf[1] = pos.y;
       chr[0] = key; // FIXME: Make this upper case?
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
      static int vCount = 0;
      static int vMax = 0;
      static int vStore = 0;
      static NSPoint *vertices = nil;
      LOG(@"IFUNC=20, Polygon fill"); // FIXME (clean this code)

      if (vMax == 0)
      {
        // First call
        vMax = (int)rbuf[0];
        vCount = 0;
        if (vMax > vStore)
        {
           // Allocate memory
           int tmpStoreSize = 2*vMax;
           if (vertices)
           {
              free(vertices);
           }
           if (vertices = (NSPoint *)malloc(tmpStoreSize*sizeof(NSPoint)))
           {
              vStore = tmpStoreSize;
              LOG(@"vStore is now: %d", vStore);
           }
           else
           {
              NSLog(@"Error allocating memory.");
           }
        }
      }
      else
      {
        if(vertices)
        {
           vertices[MIN(vCount, vStore-1)] = NSMakePoint(rbuf[0], rbuf[1]);
        }
        vCount++;
        if (vCount == vMax)
        {
           if(vertices)
           {
              [adapter addPolygonWithPoints:vertices pointCount:MIN(vMax, vStore)];
           }
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
      [adapter setColormapEntry:index red:rbuf[1] green:rbuf[2] blue:rbuf[3]];
      if(index == 0) // Background color was changed
      {
        [adapter takeBackgroundColorFromColormapEntry:0];
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
      LOG(@"IFUNC=24, Rectangle Fill");
      [adapter addFilledRect:NSMakeRect(rbuf[0], rbuf[1], rbuf[2]-rbuf[0], rbuf[3]-rbuf[1])];
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
       static unsigned char *pixPtr;
       static unsigned char *dataPtr;
       static int pixCount;
       static int lineCount;
       static NSSize bitmapSize;
       static NSRect imageBounds;
       static BOOL useTransform = YES;
       float m11=rbuf[7], m12=rbuf[8], m21=rbuf[9], m22=rbuf[10], tx=rbuf[11], ty=rbuf[12];
       float detA = m11*m22-m12*m21;

       LOG(@"IFUNC=26, Line of pixels");

       switch((int)rbuf[0])
       {
          case 0:
             // Set up memory storage and basic parameters
             bitmapSize = NSMakeSize((int)rbuf[1], (int)rbuf[2]);
             imageBounds = NSMakeRect(rbuf[3], rbuf[5], rbuf[4]-rbuf[3], rbuf[6]-rbuf[5]);
             LOG(@"bitmapsize: %@\nimageBounds: %@", NSStringFromSize(bitmapSize), NSStringFromRect(imageBounds));
             LOG(@"Matrix: %f, %f, %f, %f, %f, %f", m11, m12, m21, m22, tx, ty); 
             //
             // Invert the transform...
             //
             if (fabs(detA) > 1e-16)
             {
                float sc = 1.0/detA;
                [adapter setImageTransformM11:m22*sc m12:-m12*sc m21:-m21*sc m22:m11*sc tX:(m21*ty-m22*tx)*sc tY:(m12*tx-m11*ty)*sc];
                useTransform = YES;
             }
             else
             {
                NSLog(@"Transformation matrix not invertible. Scaling image to bounds.");
                useTransform = NO;
             }
             pixCount = 0;
             lineCount = bitmapSize.height - 1;
             pixPtr = (unsigned char *)malloc(3*bitmapSize.width*bitmapSize.height*sizeof(unsigned char));
             dataPtr = pixPtr + lineCount * (3 * (int)bitmapSize.width);
             break;
          case -1:
             // End of data indicator
             LOG(@"End.");
             if (useTransform)
             {
                [adapter addTransformedImageWithBitmap:pixPtr size:bitmapSize clipRect:imageBounds];
             }
             else
             {
                [adapter addImageWithBitmap:pixPtr size:bitmapSize bounds:imageBounds];                
             }
             [adapter resetImageTransform];
             free(pixPtr);
             break;
          default:
          {
             //
             // Write 3*n pixels to buffer
             // NB. Images in AQT are stored with upper left pixel first (flipped)
             //
             int i;
             int n = (int)rbuf[0];
             for (i = 1; i<=n; i++)
             {
                float red, green, blue;
                if(pixCount == (int)bitmapSize.width)
                {
                   pixCount = 0;
                   lineCount--;
                   dataPtr = pixPtr + lineCount * (3 * (int)bitmapSize.width);
                }
                [adapter getColormapEntry:(int)rbuf[i] red:&red green:&green blue:&blue];

                *dataPtr = (unsigned char)(255*red);
                dataPtr++;
                *dataPtr = (unsigned char)(255*green);
                dataPtr++;
                *dataPtr = (unsigned char)(255*blue);
                dataPtr++;
                pixCount++;
             }
          }
             break;
       }
    }
      break;

      //--- IFUNC=27, World-coordinate scaling --------------------------------

    case 27:
      LOG(@"IFUNC=27, World-coordinate scaling"); // FIXME (Use???)
      break;

      //--- IFUNC=28, Draw marker ---------------------------------------------
    case 28:
      LOG(@"IFUNC=28, Draw marker");
      break;

      //--- IFUNC=29, Query color representation ------------------------------
    case 29:
      [adapter getColormapEntry:(int)rbuf[0] red:&rbuf[1] green:&rbuf[2] blue:&rbuf[3]];
      *nbuf = 4;
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