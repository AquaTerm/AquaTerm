#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTProtocol.h"

/* Debugging extras */
static inline void NOOP_(id x, ...) {;}

#ifdef LOGGING
#define LOG  NSLog
#else
#define LOG  NOOP_
#endif  /* LOGGING */

#define BUFMAX 50

static NSAutoreleasePool *arpool;   // Objective-C autorelease pool
static id adapter;                          // Adapter object

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
  float orient;
  int just;
  int     polylineBufCount;
  int     polygonBufCount;
  // --- storage objects
  NSBezierPath *polylineBuffer;
  NSBezierPath *polygonBuffer;
  NSBezierPath *polygonBuf;
  NSBitmapImageRep *image;
  NSRect imageBounds;
  float colorlist[300][3];
}
- (id)init;                 // init & dealloc are listed for completeness
- (void)dealloc;
- (id)aqtConnection;        // accessor method
- (BOOL)connectToAquaTerm;      // convenience method
                                //
                                // Obj-C methods implementing the functionality defined in PGPLOT driver
                                //
- (void)openGraph:(int)n size:(NSSize)canvasSize;
- (void)closeGraph;
- (void)render;
- (void)flushPolylineBuffer;
- (void)flushPolygonBuffer;
- (void)setColorIndex:(int)colorIndex;
- (void)setLineWidth:(float)newLineWidth;
- (void)setFontWithName:(NSString *)name size:(float)size;
- (void)useOrientation:(float)orient;
- (void)useJustification:(int)just;
- (void)putText:(NSAttributedString *)str at:(NSPoint)point;
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

// ----------------------------------------------------------------
// --- Start of PlPlot function aqtrm()
// ----------------------------------------------------------------
#include "plplot/plplotP.h"
#include "plplot/drivers.h"
#include "plplot/aqtplplot.h"
#include "plplot/plDevs.h"
#include "plplot/ps.h"

/* Driver entry and dispatch setup */

void plD_dispatch_init_aqt      ( PLDispatchTable *pdt );

void plD_init_aqt               (PLStream *);
void plD_line_aqt               (PLStream *, short, short, short, short);
void plD_polyline_aqt   (PLStream *, short *, short *, PLINT);
void plD_eop_aqt                (PLStream *);
void plD_bop_aqt                (PLStream *);
void plD_tidy_aqt               (PLStream *);
void plD_state_aqt              (PLStream *, PLINT);
void plD_esc_aqt                (PLStream *, PLINT, void *);

void plD_dispatch_init_aqt( PLDispatchTable *pdt )
{
  pdt->pl_MenuStr  = "AquaTerm - Mac OS X";
  pdt->pl_DevName  = "aqt";
  pdt->pl_type     = plDevType_Interactive;
  pdt->pl_seq      = 1;
  pdt->pl_init     = (plD_init_fp)     plD_init_aqt;
  pdt->pl_line     = (plD_line_fp)     plD_line_aqt;
  pdt->pl_polyline = (plD_polyline_fp) plD_polyline_aqt;
  pdt->pl_eop      = (plD_eop_fp)      plD_eop_aqt;
  pdt->pl_bop      = (plD_bop_fp)      plD_bop_aqt;
  pdt->pl_tidy     = (plD_tidy_fp)     plD_tidy_aqt;
  pdt->pl_state    = (plD_state_fp)    plD_state_aqt;
  pdt->pl_esc      = (plD_esc_fp)      plD_esc_aqt;
}
static int currentPlot = 0;
static int maxWindows = 30;
int colorChange;

#define AQT_Max_X       (10.0*72.0)
#define AQT_Max_Y       (10.0*72.0)
#define DPI             72

//---------------------------------------------------------------------
//   aqt_init()
//
//   Initialize device
//----------------------------------------------------------------------

void plD_init_aqt(PLStream *pls)
{

  if (arpool == NULL)   /* Make sure we don't leak mem by allocating every time */
  {
    arpool = [[NSAutoreleasePool alloc] init];
    adapter = [[AQTAdapter alloc] init];
  }
  if(adapter)
  {

  }

  pls->termin = 1;                    // If interactive terminal, set true.
  pls->color = 1;                             // aqt is color terminal
  pls->width = 1;
  pls->verbose = 1;
  pls->bytecnt = 0;
  pls->debug = 1;
  pls->dev_text = 1;
  pls->page = 0;
  pls->dev_fill0 = 1;         /* supports hardware solid fills */
  pls->dev_fill1 = 1;

  pls->graphx = GRAPHICS_MODE;

  if (!pls->colorset)
    pls->color = 1;
  //
  // Set up device parameters
  //
  plP_setpxl(72./25.4, 72./25.4);           /* Pixels/mm. */
  //
  //  Set the bounds for plotting.  initially set it to be a 400 x 400 array
  //
  plP_setphy((PLINT) 0, (PLINT) (AQT_Max_X), (PLINT) 0, (PLINT) (AQT_Max_Y));

}

//----------------------------------------------------------------------
//   aqt_bop()
//
//   Set up for the next page.
//----------------------------------------------------------------------

void plD_bop_aqt(PLStream *pls)
{
  currentPlot = currentPlot>=maxWindows?0:currentPlot;
  [adapter openGraph:currentPlot++ size:NSMakeSize(AQT_Max_X, AQT_Max_Y)];
  [adapter setLineWidth:1.];

  pls->page++;
  colorChange = TRUE;
}

//---------------------------------------------------------------------
//   aqt_line()
//
//   Draw a line in the current color from (x1,y1) to (x2,y2).
//----------------------------------------------------------------------

void plD_line_aqt(PLStream *pls, short x1a, short y1a, short x2a, short y2a)
{
  if(colorChange) {
    [adapter setColorIndex:(1-pls->curcmap)*pls->icol0 + pls->curcmap*(pls->icol1+pls->ncol0)];
    colorChange = FALSE;
  }

  [adapter lineFromPoint:NSMakePoint((int) x1a + .3, (int) y1a + .3)
                 toPoint:NSMakePoint((int) x2a + .3, (int) y2a + .3)];

}

//---------------------------------------------------------------------
//  aqt_polyline()
//
// Draw a polyline in the current color.
//---------------------------------------------------------------------

void plD_polyline_aqt(PLStream *pls, short *xa, short *ya, PLINT npts)
{
  int i;

  for (i = 0; i < npts - 1; i++)
    plD_line_aqt(pls, xa[i], ya[i], xa[i + 1], ya[i + 1]);

}

//---------------------------------------------------------------------
//   aqt_eop()
//
//   End of page
//---------------------------------------------------------------------

void plD_eop_aqt(PLStream *pls)
{

  [adapter closeGraph];

}

//---------------------------------------------------------------------
// aqt_tidy()
//
// Close graphics file or otherwise clean up.
//---------------------------------------------------------------------

void plD_tidy_aqt(PLStream *pls)
{

  [adapter closeGraph];

}
//---------------------------------------------------------------------
//  plD_state_aqt()
//
//  Handle change in PLStream state (color, pen width, fill attribute, etc).
//---------------------------------------------------------------------

void plD_state_aqt(PLStream *pls, PLINT op)
{
  int i;

  switch (op) {
    case PLSTATE_WIDTH:
      [adapter setLineWidth:(float)pls->width];
      break;

    case PLSTATE_COLOR0:
    case PLSTATE_COLOR1:
    case PLSTATE_FILL:
      i = (1-pls->curcmap)*pls->icol0 + pls->curcmap*(pls->icol1+pls->ncol0);
      [adapter setColormapEntry:i red:(float)(plsc->curcolor.r/255.)
                          green:(float)(plsc->curcolor.g/255.)
                           blue:(float)(plsc->curcolor.b/255.)];
      colorChange = TRUE;
      break;

    case PLSTATE_CMAP0:
      for (i = 0; i < pls->ncol0; i++) {
        [adapter setColormapEntry:i red:(float)(plsc->cmap0[i].r/255.)
                            green:(float)(plsc->cmap0[i].g/255.)
                             blue:(float)(plsc->cmap0[i].b/255.)];
      }
      colorChange = TRUE;
      //
      //  Make sure the background color is set to the current color map
      //
      [adapter setColormapEntry:-4 red:(float)(plsc->cmap0[0].r/255.)
                          green:(float)(plsc->cmap0[0].g/255.)
                           blue:(float)(plsc->cmap0[0].b/255.)];

      break;

    case PLSTATE_CMAP1:
      for (i = 0; i < pls->ncol1; i++) {
        [adapter setColormapEntry:i+pls->ncol0 red:(float)(plsc->cmap1[i].r/255.)
                            green:(float)(plsc->cmap1[i].g/255.)
                             blue:(float)(plsc->cmap1[i].b/255.)];
      }
      colorChange = TRUE;
      break;
  }
}

//---------------------------------------------------------------------
// aqt_esc()
//
// Escape function.
//
// Functions:
//
//      PLESC_EH                Handle pending events
//      PLESC_EXPOSE    Force an expose
//      PLESC_FILL              Fill polygon
//  PLESC_FLUSH         Flush X event buffer
//      PLESC_GETC              Get coordinates upon mouse click
//      PLESC_REDRAW    Force a redraw
//      PLESC_RESIZE    Force a resize
//---------------------------------------------------------------------
//
void plD_esc_aqt(PLStream *pls, PLINT op, void *ptr)
{
  int     i;
  switch (op)
  {
    case PLESC_EXPOSE:              // handle window expose
      break;
    case PLESC_RESIZE:              // handle window resize
      break;
    case PLESC_REDRAW:              // handle window redraw
      break;
    case PLESC_TEXT:                // switch to text screen
      break;
    case PLESC_GRAPH:               // switch to graphics screen
      break;
    case PLESC_FILL:                // fill polygon

      [adapter beginPolygon];

      if(colorChange) {
        [adapter setColorIndex:(1-pls->curcmap)*pls->icol0 + pls->curcmap*(pls->icol1+pls->ncol0)];
        colorChange = FALSE;
      }

        for (i = 0; i < pls->dev_npts ; i++)
          [adapter addPolygonEdgeToPoint:NSMakePoint(pls->dev_x[i], pls->dev_y[i])];

        [adapter fillPolygon];

      break;
    case PLESC_DI:                  // handle DI command
      break;
    case PLESC_FLUSH:               // flush output
      break;
    case PLESC_EH:          // handle Window events
      break;
    case PLESC_GETC:                // get cursor position
      break;
    case PLESC_SWIN:                // set window parameters
      break;
    case PLESC_HAS_TEXT:
      proc_str(pls, (EscText *)ptr);
      break;

  }
}
void proc_str (PLStream *pls, EscText *args)
{
  PLFLT   *t = args->xform;
  PLFLT   a1, alpha, ft_ht, angle, ref;
  PLINT   clxmin, clxmax, clymin, clymax;
  char    str[128], fontn[128], updown[128], esc, *strp;
  const char *cur_str;
  char    *font, *ofont;
  float   ft_scale;
  int             i, jst, symbol, length, ltmp;
  NSMutableAttributedString  *s;
  char    char_ind;
  unichar Greek[53] = {
    0X391, 0X392, 0X3A7, 0X394, 0X395, 0X3A6, 0X393, 0X397,
    0X399, 0X3D1, 0X39A, 0X39B, 0X39C, 0X39D, 0X39F, 0X3A0,
    0X398, 0X3A1, 0X3A3, 0X3A4, 0X3A5, 0X3A7, 0X3A9, 0X39E,
    0X3A8, 0X396, 0X3B1, 0X3B2, 0X3C7, 0X3B4, 0X3B5, 0X3D5,
    0X3B3, 0X3B7, 0X3B9, 0X3C6, 0X3BA, 0X3BB, 0X3BC, 0X3BD,
    0X3BF, 0X3C0, 0X3B8, 0X3C1, 0X3C3, 0X3C4, 0X3C5, 0X3DB,
    0X3C9, 0X3BE, 0X3C8, 0X3B6, 0x003F};

  //  Set the font height - the 1.2 factor was trial and error

  ft_ht = 1.2*pls->chrht * 72.0/25.4; /* ft_ht in points. ht is in mm */

  //  Now find the angle of the text relative to the screen...
  //
  angle = pls->diorot * 90.;
  a1 = acos(t[0]) * 180. / PI;
  if (t[2] > 0.)
    alpha = a1 - angle;
  else
    alpha = 360. - a1 - angle;

  alpha = alpha * PI / 180.;
  [adapter useOrientation:alpha];

  //
  // any transformation if there is one - normally on text there isn't any
  //
  difilt(&args->x, &args->y, 1, &clxmin, &clxmax, &clymin, &clymax);

  //     check clip limits. For now, only the reference point of the string is checked;
  //     but the the whole string should be checked

  if ( args->x < clxmin || args->x > clxmax || args->y < clymin || args->y > clymax)
    return;

  //   * Text justification.  Left, center and right justification, which
  //   *  are the more common options, are supported; variable justification is
  //   *  only approximate, based on plplot computation of it's string lenght

  if (args->just < 0.33){
    jst = 0;                                         /* left */
  }
  else if (args->just > 0.66){
    jst = 2;                                        /* right */
  }
  else {
    jst = 1;                                        /* center */
  }

  [adapter useJustification:jst];

  /*
   * Reference point (center baseline of string).
   *  If base = 0, it is aligned with the center of the text box
   *  If base = 1, it is aligned with the baseline of the text box
   *  If base = 2, it is aligned with the top of the text box
   *  Currently plplot only uses base=0
   */

  if (args->base == 2) /* not supported by plplot */
    ref = - DPI/72. * ft_ht / 2.;
  else if (args->base == 1)
    ref = 0.;
  else
    ref = DPI/72. * ft_ht / 2.;
  //
  //  Set the default font
  //
  switch (pls->cfont) {
    case 1: ofont = "Times-Roman";  fontn[0]=1; break;
    case 2: ofont = "Times-Roman";  fontn[0]=2; break;
    case 3: ofont = "Times-Italic"; fontn[0]=3; break;
    case 4: ofont = "Helvetica";    fontn[0]=4; break;
    default:  ofont = "Times-Roman";fontn[0]=1;
  }

  //  Get a purged string for testing

  plgesc(&esc);

  length=0;
  esc_purge(str, args->string);


  //  set font and super/subscriptsfor each character
  do{
    updown[length]=0;
    fontn[length]=fontn[0];
  }while(str[length++] && length < 128);
  fontn[--length]=0;

  cur_str = args->string;

  strp = str;

  do {
    symbol = 0;

    if (*cur_str == esc) {
      cur_str++;

      if (*cur_str == esc) {
        // <esc><esc>
        *strp++ = *cur_str++;
      }
      else switch (*cur_str) {

        case 'f':
          //  Change font
          cur_str++;
          switch (*cur_str) {
            case 'n': font = "Times-Roman";
              fontn[strp-str]=1; break;
            case 'r': font = "Times-Roman";
              fontn[strp-str]=2; break;
            case 'i': font = "Times-Italic";
              fontn[strp-str]=3; break;
            case 's': font = "Helvetica";
              fontn[strp-str]=4; break;
            default:  font = "Times-Roman";
              fontn[strp-str]=1;
          }
            //  set new font for rest of string or until next font change
            ltmp=strp-str;
          do{
            fontn[ltmp++]=fontn[strp-str];
          }while(ltmp < length);

            cur_str++;
          break;

        case 'g':
          // Greek Letters are single characters
          cur_str++;
          fontn[strp-str]=5; break;
          *strp++ = *cur_str++;
          break;

        case 'd':
          // Subscript not used
          ltmp=strp-str;
          do{
            updown[ltmp++]--;
          }while(ltmp < length);
            cur_str++;
          break;

        case 'u':
          // Superscript not used
          ltmp=strp-str;
          do{
            updown[ltmp++]++;
          }while(ltmp < length);
            cur_str++;
          break;

          /* ignore the next sequences */

        case '+':
        case '-':
        case 'b':
          // plwarn("'+', '-', and 'b' text escape sequences not processed.");
          cur_str++;
          break;

        case '(':
          // plwarn("'g(...)' text escape sequence not processed.");
          while (*cur_str++ != ')');
          *strp++ = 'x';                              //  Plplot uses #(229) for x in exponent
          break;
      }
    }
      // copy from current to next token

      while(!symbol && *cur_str && *cur_str != esc) {
        *strp++ = *cur_str++;
      }
      *strp = '\0';

  } while(*cur_str);

    //  Now we create an attributed string
    //
    s = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithCString:str]];
    //
    //  Set the default font and color for the string before we do anything else
    //
    [s addAttribute:NSFontAttributeName
              value:[NSFont fontWithName:[NSString stringWithCString:ofont] size:ft_ht]
              range:NSMakeRange(0, length)];

    [s addAttribute:NSForegroundColorAttributeName
              value:[NSColor colorWithCalibratedRed:(float)(pls->curcolor.r/255.)
                                              green:(float)(pls->curcolor.g/255.)
                                               blue:(float)(pls->curcolor.b/255.)
                                              alpha:1.]
              range:NSMakeRange(0, length)];

    //
    //  Set the font
    for(i = 0; i < length; i++){
      ft_scale=1.;
      switch (fontn[i]) {
        case 1: font = "Times-Roman";  break;
        case 2: font = "Times-Roman";  break;
        case 3: font = "Times-Italic"; break;
        case 4: font = "Helvetica";    break;
        case 5: font = "Symbol";    break;
        default:  font = "Times-Roman";
      }
      //
      //  Set Greek Characters
      if(fontn[i]==5){
        if((str[i] >= 'A' && str[i] <= 'Z') || (str[i] >= 'a' && str[i] <= 'z')) {
          char_ind = (char) str[i] - 'A';
          if(char_ind >= 32)
            char_ind -=6;

          if(char_ind < 0 || char_ind > 51 )
            char_ind = 52;

          [s replaceCharactersInRange:NSMakeRange(i, 1)
                           withString:[NSString stringWithCharacters:Greek+char_ind length:1]];
        }
      }
      //
      //  Set Super and subscripts

      if(updown[i]!=0){
        [s addAttribute:NSSuperscriptAttributeName
                  value:[NSNumber numberWithInt:updown[i]]
                  range:NSMakeRange(i, 1)];
        ft_scale=.6;
      }


      [s addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:[NSString stringWithCString:font] size:ft_ht*ft_scale]
                range:NSMakeRange(i, 1)];

    }

    [adapter putText:s at:NSMakePoint(args->x, args->y)];

    [s release];

}
static void
esc_purge(char *dstr, const char *sstr)
{
  char esc;

  plgesc(&esc);

  while(*sstr){
    if (*sstr != esc) {
      *dstr++ = *sstr++;
      continue;
    }

    sstr++;
    if (*sstr == esc)
      continue;
    else {
      switch(*sstr++) {
        //                              case 'g':
        case 'f':
          sstr++;
          break; /* two chars sequence */

        case '(':
          while (*sstr++ != ')'); /* multi chars s
                 equence */
          *dstr++ = 'x';                              //  Plplot uses #(229) for x in exponent
          break;

        default:
          break;  /* single char escape */
      }
    }
  }
  *dstr = '\0';
}

// ----------------------------------------------------------------
// --- End of PlPLOT function aqtrm()
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
  if (self = [super init]){
    //
    // Try to get a local proxy of the object in AquaTerm that manages communication
    //
    if ([self connectToAquaTerm]){
      // Init instance variables
      polylineBuffer = [[NSBezierPath bezierPath] retain];
      polygonBuffer = [[NSBezierPath bezierPath] retain];
      polygonBuf = [[NSBezierPath bezierPath] retain];

      for (i=16+4;i<256+16+4;i++){
        colorlist[i][0]=((float)i-16-4)/255.0;
        colorlist[i][1]=((float)i-16-4)/255.0;
        colorlist[i][2]=((float)i-16-4)/255.0;
      }
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

- (void)dealloc
{
  [aqtConnection release];
  [polygonBuf release];
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
  if (aqtConnection){                                     /* Server is running and ready to go */
    [aqtConnection retain];
    didConnect = YES;
  }
  else{ /* Server isn't running, we must fire it up */
  //
  // Try to launch AquaTerm
  //
  if ([[NSWorkspace sharedWorkspace] launchApplication:@"AquaTerm"] == NO){
    printf("Failed to launch AquaTerm.\n");
    printf("You must either put AquaTerm.app in \n");
    printf("the /Applications or ~/Applications folder\n");
  }
  else{
    do {                    /* Wait for it to register with
      OS */
      aqtConnection =[NSConnection rootProxyForConnectionWithRegisteredName:@"aquatermServer" host:nil];
    }
    while (!aqtConnection)
      ;  /* This could result in a hang
    if something goes wrong with registering! */
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
  currentColor = colorIndex;
}

- (void)setLineWidth:(float)newLineWidth
{
  //
  // This requires flushing of the polyline buffer
  //
  [self flushPolylineBuffer];
  newLineWidth = newLineWidth*0.01*72;
  // Limit thinnest line
  lineWidth=(newLineWidth>10.?10.:(newLineWidth<1.?1:newLineWidth));
}

- (void)openGraph:(int)n size:(NSSize)canvasSize
{
  //
  // Select a "model"
  //
  [aqtConnection openModel:n size:canvasSize];
}

- (void)closeGraph
{
  //int i,r,g,b;
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
  [polygonBuffer appendBezierPath:thePath];
  polygonBufCount +=1;
  if (polygonBufCount > BUFMAX)
    [self flushPolygonBuffer];
}

- (void) fillRect:(NSRect)aRect
{
  NSBezierPath *thePath = [NSBezierPath bezierPathWithRect:aRect];
  //
  // close up the path and send the polygonBuf to AquaTerm
  //
  [thePath closePath];
  [polygonBuffer appendBezierPath:thePath];
  polygonBufCount +=4;
  if (polygonBufCount > BUFMAX)
    [self flushPolygonBuffer];
}
//
// --- PlPLOT uses a sequence of calls to build a polygon
//
- (void)beginPolygon {
  [polygonBuf removeAllPoints];
}

- (void)addPolygonEdgeToPoint:(NSPoint)aPoint{
  if ([polygonBuf isEmpty]){
    [polygonBuf moveToPoint:aPoint];
  }
  else{
    [polygonBuf lineToPoint:aPoint];
  }
  polygonBufCount +=1;
}

- (void)fillPolygon
{
  [polygonBuf closePath];
  [polygonBuffer appendBezierPath:polygonBuf];
  if (polygonBufCount > BUFMAX){
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

  [image getBitmapDataPlanes:dataPlanes];
  for(i=0;i<len;i++) {
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
  [aqtConnection setColor:tempColor forIndex:i];
  // Set r,g and b values of the i:th color in local colormap
  if(i >= 0) {
    colorlist[i][0]=r;
    colorlist[i][1]=g;
    colorlist[i][2]=b;
  }
}
-(NSColor *)colormapEntry:(int)i
{
  // return an NSColor object with r,g and b values of the i:th color in local colormap
  return [NSColor colorWithCalibratedRed:colorlist[i][0] green:colorlist[i][1] blue:colorlist[i][2] alpha:1.0];
}

-(void)setFontWithName:(NSString *)name size:(float)size
{
  [aqtConnection setFontWithName:name size:size];
}

-(void)useOrientation:(float)newOrient
{
  orient = newOrient;
}

-(void)useJustification:(int)newJust
{
  just = newJust;
}

-(void)putText:(NSAttributedString *)str at:(NSPoint)point
{
  //Flush the buffers and then write out an Attributed string to the model..
  //

  [self flushPolygonBuffer];
  [self flushPolylineBuffer];

  [aqtConnection addAttributedString:str
                             atPoint:point
                   withJustification:just
                             atAngle:57.295779*orient];
}

@end
// ----------------------------------------------------------------
// --- End of AQTAdapter class
// ----------------------------------------------------------------
