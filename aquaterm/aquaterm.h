//
//  aquaterm.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c  2003 AquaTerm. All rights reserved.
//

#define EVENTBUF_SIZE 128

/*" Constants that specify linecap styles. "*/
extern const int AQTButtLineCapStyle;
extern const int AQTRoundLineCapStyle;
extern const int AQTSquareLineCapStyle;

/*" Constants that specify horizontal alignment for labels. "*/
extern const int AQTAlignLeft;
extern const int AQTAlignCenter;
extern const int AQTAlignRight;
/*" Constants that specify vertical alignment for labels. "*/
extern const int AQTAlignMiddle;
extern const int AQTAlignBaseline;
extern const int AQTAlignBottom;
extern const int AQTAlignTop;

/*" Class initialization etc."*/
int aqtInit(void);
void aqtSetErrorHandler(void (*func)(const char *msg));
void aqtSetEventHandler(void (*func)(int ref, const char *event));

   /*" Control operations "*/
void aqtOpenPlot(int refNum); 
int aqtSelectPlot(int refNum); 
void aqtSetPlotSize(float width, float height); 
void aqtSetPlotTitle(const char *title);
void aqtRenderPlot(void);
void aqtClearPlot(void);
void aqtClosePlot(void);

   /*" Event handling "*/
void aqtSetAcceptingEvents(int flag);
int aqtGetLastEvent(char *buffer);
int aqtWaitNextEvent(char *buffer);

   /*" Plotting related commands "*/

   /*" Colormap (utility  "*/
int aqtColormapSize(void);
void aqtSetColormapEntry(int entryIndex, float r, float g, float b);
void aqtGetColormapEntry(int entryIndex, float *r, float *g, float *b);
void aqtTakeColorFromColormapEntry(int index);  // <-- rename?
void aqtTakeBackgroundColorFromColormapEntry(int index); // <-- rename?

   /*" Color handling "*/
void aqtSetColor(float r, float g, float b);
void aqtSetBackgroundColor(float r, float g, float b);
void aqtGetCurrentColor(float *r, float *g, float *b);;

   /*" Text handling "*/
void aqtSetFontname(const char *newFontname);
void aqtSetFontsize(float newFontsize); 
void aqtAddLabel(const char *text, float x, float y, float angle, int align);

   /*" Line handling "*/
void aqtSetLinewidth(float newLinewidth); 
void aqtSetLineCapStyle(int capStyle); 
void aqtMoveTo(float x, float y); 
void aqtAddLineTo(float x, float y); 
void aqtAddPolyline(float *x, float *y, int pointCount); 

   /*" Rect and polygon handling"*/

void aqtMoveToVertex(float x, float y); 
void aqtAddEdgeToVertex(float x, float y); 
void aqtAddPolygon(float *x, float *y, int pointCount); 
void aqtAddFilledRect(float originX, float originY, float width, float height); 
void aqtEraseRect(float originX, float originY, float width, float height); 

   /*" Image handling "*/
/*
 void aqtSetImageTransformM11(float m11, float m12, float m21, float m22, float tX, float tY);
void aqtResetImageTransform(void);
void aqtAddImageWithBitmap(const void *bitmap, NSSize bitmapSize, NSRect destBounds);
void aqtAddTransformedImageWithBitmap(const void *bitmap, NSSize bitmapSize, NSRect destBounds);
*/
