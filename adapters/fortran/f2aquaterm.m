//
//  f2aquaterm.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//
#include <aquaterm/aquaterm.h>
void _f2aqtConvertString(char *dst, int dstLen, const char *src, int srcLen)
{
   int n = (srcLen > dstLen-1)?dstLen-1:srcLen;
   (void)strncpy(dst, src, n);
   dst[n] = '\0';
   printf("Converted: %s, (%d)\n", dst, strlen(dst));
}
/*" Class initialization etc."*/
int aqtInit_(void) // FIXME: retval?
{
   return aqtInit();
}

void aqtTerminate_(void)
{
   aqtTerminate();
}

/*" Control operations "*/
void aqtOpenPlot_(int *refNum) // FIXME: retval?
{
   aqtOpenPlot(*refNum);
}

int aqtSelectPlot_(int *refNum) // FIXME: retval?
{
   return aqtSelectPlot(*refNum);
}

void aqtSetPlotSize_(float *width, float *height)
{
   aqtSetPlotSize(*width, *height);
}

void aqtSetPlotTitle_(const char *title, int strLen) // FIXME: Fortran calling conventions
{
   char strBuf[32];
   _f2aqtConvertString(strBuf, sizeof(strBuf), title, strLen);
   aqtSetPlotTitle(strBuf);
}

void aqtRenderPlot_(void)
{
   aqtRenderPlot();
}

void aqtClearPlot_(void)
{
   aqtClearPlot();
}

void aqtClosePlot_(void)
{
   aqtClosePlot();
}

/*" Event handling "*/
int aqtWaitNextEvent_(char *buffer) // FIXME: retval?
{
   return aqtWaitNextEvent(buffer);
}

/*" Plotting related commands "*/

/*" Colormap (utility  "*/
int aqtColormapSize_(void)
{
   return aqtColormapSize();
}

void aqtSetColormapEntry_(int *entryIndex, float *r, float *g, float *b)
{
   aqtSetColormapEntry(*entryIndex, *r, *g, *b);
}

void aqtGetColormapEntry_(int *entryIndex, float *r, float *g, float *b)
{
   aqtGetColormapEntry(*entryIndex, r, g, b);
}

void aqtTakeColorFromColormapEntry_(int *index)
{
   aqtTakeColorFromColormapEntry(*index);
}

void aqtTakeBackgroundColorFromColormapEntry_(int *index)
{
   aqtTakeBackgroundColorFromColormapEntry(*index);
}

/*" Color handling "*/
void aqtSetColor_(float *r, float *g, float *b)
{
   aqtSetColor(*r, *g, *b);
}

void aqtSetBackgroundColor_(float *r, float *g, float *b)
{
   aqtSetBackgroundColor(*r, *g, *b);
}

void aqtGetCurrentColor_(float *r, float *g, float *b)
{
   aqtGetCurrentColor(r, g, b);
}

/*" Text handling "*/
 void aqtSetFontname_(const char *newFontname, int strLen)
{
    char strBuf[64];
    _f2aqtConvertString(strBuf, sizeof(strBuf), newFontname, strLen);
    aqtSetFontname(strBuf);
}

void aqtSetFontsize_(float *newFontsize)
{
   aqtSetFontsize(*newFontsize);
}

void aqtAddLabel_(const char *text, float *x, float *y, float *angle, int *align, int strLen)
{
   char strBuf[64];
   _f2aqtConvertString(strBuf, sizeof(strBuf), text, strLen);
   aqtAddLabel(strBuf, *x, *y, *angle, *align);
}

/*" Line handling "*/
void aqtSetLinewidth_(float *newLinewidth)
{
   aqtSetLinewidth(*newLinewidth);
}

void aqtSetLineCapStyle_(int *capStyle)
{
   aqtSetLineCapStyle(*capStyle);
}

void aqtMoveTo_(float *x, float *y)
{
   aqtMoveTo(*x, *y);
}

void aqtAddLineTo_(float *x, float *y)
{
   aqtAddLineTo(*x, *y);
}

void aqtAddPolyline_(float *x, float *y, int *pc)
{
   aqtAddPolyline(x, y, *pc);
}

/*" Rect and polygon handling"*/
 void aqtMoveToVertex_(float *x, float *y)
{
    aqtMoveToVertex(*x, *y);
}

void aqtAddEdgeToVertex_(float *x, float *y)
{
   aqtAddEdgeToVertex(*x, *y);
}

void aqtAddPolygon_(float *x, float *y, int *pc)
{
   aqtAddPolygon(x, y, *pc);
}

void aqtAddFilledRect_(float *originX, float *originY, float *width, float *height)
{
   aqtAddFilledRect(*originX, *originY, *width, *height);
}

void aqtEraseRect_(float *originX, float *originY, float *width, float *height)
{
   aqtEraseRect(*originX, *originY, *width, *height);
}

/*" Image handling "*/
 void aqtSetImageTransform_(float *m11, float *m12, float *m21, float *m22, float *tX, float *tY)
{
    aqtSetImageTransform(*m11, *m12, *m21, *m22, *tX, *tY);
}

void aqtResetImageTransform_(void)
{
   aqtResetImageTransform();
}

void aqtAddImageWithBitmap_(const void *bitmap, int *pixWide, int *pixHigh, float *originX, float *originY, float *width, float *height)
{
   aqtAddImageWithBitmap(bitmap, *pixWide, *pixHigh, *originX, *originY, *width, *height);
}

void aqtAddTransformedImageWithBitmap_(const void *bitmap, int *pixWide, int *pixHigh, float *originX, float *originY, float *width, float *height)
{
   aqtAddTransformedImageWithBitmap(bitmap, *pixWide, *pixHigh, *originX, *originY, *width, *height);
}

