//
//  f2aquaterm.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//
#include <AquaTerm/aquaterm.h>
#include <string.h>

void _f2aqtconvertstring(char *dst, int dstLen, const char *src, int srcLen)
{
   int n = (srcLen > dstLen-1)?dstLen-1:srcLen;
   (void)strncpy(dst, src, n);
   dst[n] = '\0';
   // printf("Converted: %s, (%d)\n", dst, strlen(dst));
}
/*" Class initialization etc."*/
int aqtinit_(void) // FIXME: retval?
{
   return aqtInit();
}

void aqtterminate_(void)
{
   aqtTerminate();
}

/*" Control operations "*/
void aqtopenplot_(int *refNum) // FIXME: retval?
{
   aqtOpenPlot(*refNum);
}

int aqtselectplot_(int *refNum) // FIXME: retval?
{
   return aqtSelectPlot(*refNum);
}

void aqtsetplotsize_(float *width, float *height)
{
   aqtSetPlotSize(*width, *height);
}

void aqtsetplottitle_(const char *title, int strLen) // FIXME: Fortran calling conventions
{
   char strBuf[32];
   _f2aqtconvertstring(strBuf, sizeof(strBuf), title, strLen);
   aqtSetPlotTitle(strBuf);
}

void aqtrenderplot_(void)
{
   aqtRenderPlot();
}

void aqtclearplot_(void)
{
   aqtClearPlot();
}

void aqtcloseplot_(void)
{
   aqtClosePlot();
}

/*" Event handling "*/
int aqtwaitnextevent_(char *buffer) // FIXME: retval?
{
   return aqtWaitNextEvent(buffer);
}

/*" Plotting related commands "*/

/*" Colormap (utility  "*/
int aqtcolormapsize_(void)
{
   return aqtColormapSize();
}

void aqtsetcolormapentry_(int *entryIndex, float *r, float *g, float *b)
{
   aqtSetColormapEntry(*entryIndex, *r, *g, *b);
}

void aqtgetcolormapentry_(int *entryIndex, float *r, float *g, float *b)
{
   aqtGetColormapEntry(*entryIndex, r, g, b);
}

void aqttakecolorfromcolormapentry_(int *index)
{
   aqtTakeColorFromColormapEntry(*index);
}

void aqttakebackgroundcolorfromcolormapentry_(int *index)
{
   aqtTakeBackgroundColorFromColormapEntry(*index);
}

/*" Color handling "*/
void aqtsetcolor_(float *r, float *g, float *b)
{
   aqtSetColor(*r, *g, *b);
}

void aqtsetbackgroundcolor_(float *r, float *g, float *b)
{
   aqtSetBackgroundColor(*r, *g, *b);
}

void aqtgetcolor_(float *r, float *g, float *b)
{
   aqtGetColor(r, g, b);
}

/*" Text handling "*/
 void aqtsetfontname_(const char *newFontname, int strLen)
{
    char strBuf[64];
    _f2aqtconvertstring(strBuf, sizeof(strBuf), newFontname, strLen);
    aqtSetFontname(strBuf);
}

void aqtsetfontsize_(float *newFontsize)
{
   aqtSetFontsize(*newFontsize);
}

void aqtaddlabel_(const char *text, float *x, float *y, float *angle, int *align, int strLen)
{
   char strBuf[64];
   _f2aqtconvertstring(strBuf, sizeof(strBuf), text, strLen);
   aqtAddLabel(strBuf, *x, *y, *angle, *align);
}

/*" Line handling "*/
void aqtsetlinewidth_(float *newLinewidth)
{
   aqtSetLinewidth(*newLinewidth);
}

void aqtsetlinecapstyle_(int *capStyle)
{
   aqtSetLineCapStyle(*capStyle);
}

void aqtmoveto_(float *x, float *y)
{
   aqtMoveTo(*x, *y);
}

void aqtaddlineto_(float *x, float *y)
{
   aqtAddLineTo(*x, *y);
}

void aqtaddpolyline_(float *x, float *y, int *pc)
{
   aqtAddPolyline(x, y, *pc);
}

/*" Rect and polygon handling"*/
 void aqtmovetovertex_(float *x, float *y)
{
    aqtMoveToVertex(*x, *y);
}

void aqtaddedgetovertex_(float *x, float *y)
{
   aqtAddEdgeToVertex(*x, *y);
}

void aqtaddpolygon_(float *x, float *y, int *pc)
{
   aqtAddPolygon(x, y, *pc);
}

void aqtaddfilledrect_(float *originX, float *originY, float *width, float *height)
{
   aqtAddFilledRect(*originX, *originY, *width, *height);
}

void aqteraserect_(float *originX, float *originY, float *width, float *height)
{
   aqtEraseRect(*originX, *originY, *width, *height);
}

/*" Image handling "*/
 void aqtsetimagetransform_(float *m11, float *m12, float *m21, float *m22, float *tX, float *tY)
{
    aqtSetImageTransform(*m11, *m12, *m21, *m22, *tX, *tY);
}

void aqtresetimagetransform_(void)
{
   aqtResetImageTransform();
}

void aqtaddimagewithbitmap_(const void *bitmap, int *pixWide, int *pixHigh, float *originX, float *originY, float *width, float *height)
{
   aqtAddImageWithBitmap(bitmap, *pixWide, *pixHigh, *originX, *originY, *width, *height);
}

void aqtaddtransformedimagewithbitmap_(const void *bitmap, int *pixWide, int *pixHigh, float *originX, float *originY, float *width, float *height)
{
   aqtAddTransformedImageWithBitmap(bitmap, *pixWide, *pixHigh, *originX, *originY, *width, *height);
}

