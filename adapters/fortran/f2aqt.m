#include "f2aqt.h"
#include <math.h>
#include "aquaterm/aquaterm.h"
//
// ----------------------------------------------------------------
// --- FORTRAN adapter for AquaTerm 
// ----------------------------------------------------------------
//

#define MIN(A,B) (((A) < (B)) ? (A) : (B))

#define AQT_X_MAX 800
#define AQT_Y_MAX 600

void aqt_init_(void)
{
   aqtInit();
}

void aqt_open_(int *n)
{
   aqtOpenPlot(*n);
   aqtSetPlotSize(AQT_X_MAX, AQT_Y_MAX);
   aqtSetPlotTitle("Untitled");
}

void aqt_close_(void)
{
  aqtClosePlot();
}

void aqt_flush_(void)
{
   // Not needed;
}


void aqt_render_(void)
{
   aqtRenderPlot();
}

void aqt_title_(char *title, unsigned len)
{
   char strBuf[64];
   strncpy(strBuf, title, MIN(MIN(strlen(title), len), 64));
   strBuf[63] = '\0';
   aqtSetPlotTitle(strBuf);
}

void aqt_use_color_(int *col)
{
   aqtTakeColorFromColormapEntry(*col);
}

void aqt_set_color_(int *col, float *r, float *g, float *b)
{
   aqtSetColormapEntry(*col, *r, *g, *b);
}

void aqt_linewidth_(float *width)
{
  aqtSetLinewidth(*width);
}

void aqt_line_(float *x1, float *y1, float *x2, float *y2)
{
  aqtMoveTo(*x1, *y1);
  aqtAddLineTo(*x2, *y2);
}

void aqt_polygon_(float *x, float *y, int *n, int *isFilled)
{
  int i;
  if (*isFilled)
  {
     aqtMoveToVertex(x[0], y[0]);
     for (i = 1; i < *n; i++)
     {
        aqtAddEdgeToVertex(x[i], y[i]);
     }
  }
  else
  {
     aqtMoveTo(x[0], y[0]);
     for (i = 1; i < *n; i++)
     {
        aqtAddLineTo(x[i], y[i]);
     }
  }
}

#define F2AQT_CIRCLE_POINTS 32

void aqt_circle_(float *x, float *y, float *radius, int *isFilled)
{
   float xPtr[F2AQT_CIRCLE_POINTS], yPtr[F2AQT_CIRCLE_POINTS];
   double angle = 0.0;
   double pi = 4.0*atan(1.0);
   int n = F2AQT_CIRCLE_POINTS;
   int i;
   
   for (i=0 ; i<n; i++)
   {
      xPtr[i] = (float)(*x + *radius * cos(angle));
      yPtr[i] = (float)(*y + *radius * sin(angle));
      angle += 2.0*pi/(double)n;
   }
   aqt_polygon_(xPtr, yPtr, &n, isFilled);
}

void aqt_font_(char *fontname, float *size, unsigned len)
{
   char strBuf[64];
   strncpy(strBuf, fontname, MIN(MIN(strlen(fontname), len), 64));
   strBuf[63] = '\0';
   aqtSetFontname(strBuf);
   aqtSetFontsize(*size);
}

static float _textAngle = 0.0; 
void aqt_textorient_(int *orient)
{
   if (*orient)
      _textAngle = 90.0;
   else
      _textAngle = 0.0;
}

static int _textAlign = 0;
void aqt_textjust_(int *just)
{
    _textAlign = *just;
}

void aqt_text_(float *x, float *y, char *str, unsigned len)
{
   char strBuf[64];
   strncpy(strBuf, str, MIN(MIN(strlen(str), len), 64));
   strBuf[63] = '\0';
   aqtAddLabel(strBuf, *x, *y, _textAngle, _textAlign);
}

void aqt_image_(char *filename, float *x, float *y, float *w, float *h, unsigned len)
{
 // Not implemented
}

void aqt_get_size_(float *x_max, float *y_max)
{
   *x_max = AQT_X_MAX;
   *y_max = AQT_Y_MAX;
}
//
// ----------------------------------------------------------------
// --- End of FORTRAN example
// ----------------------------------------------------------------
//
