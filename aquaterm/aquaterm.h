//
//  aquaterm.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003-2004 AquaTerm. 
//

#define AQT_EVENTBUF_SIZE 128

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
void aqtTerminate(void);
/* The event handler callback functionality should be used with caution, it may 
   not be safe to use in all circumstances. It is certainly _not_ threadsafe. 
   If in doubt, use aqtWaitNextEvent() instead. */
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

/*" Clip rect, applies to all objects "*/
void aqtSetClipRect(float originX, float originY, float width, float height);
void aqtSetDefaultClipRect(void);

/*" Colormap (utility  "*/
int aqtColormapSize(void);
void aqtSetColormapEntry(int entryIndex, float r, float g, float b);
void aqtGetColormapEntry(int entryIndex, float *r, float *g, float *b);
void aqtTakeColorFromColormapEntry(int index);
void aqtTakeBackgroundColorFromColormapEntry(int index);

/*" Color handling "*/
void aqtSetColor(float r, float g, float b);
void aqtSetBackgroundColor(float r, float g, float b);
void aqtGetColor(float *r, float *g, float *b);
void aqtGetBackgroundColor(float *r, float *g, float *b);

/*" Text handling "*/
void aqtSetFontname(const char *newFontname);
void aqtSetFontsize(float newFontsize);
void aqtAddLabel(const char *text, float x, float y, float angle, int align);
void aqtAddShearedLabel(const char *text, float x, float y, float angle, float shearAngle, int align);

/*" Line handling "*/
void aqtSetLinewidth(float newLinewidth);
void aqtSetLinestylePattern(float *newPattern, int newCount, float newPhase);
void aqtSetLinestyleSolid(void);
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
void aqtSetImageTransform(float m11, float m12, float m21, float m22, float tX, float tY);
void aqtResetImageTransform(void);
void aqtAddImageWithBitmap(const void *bitmap, int pixWide, int pixHigh, float destX, float destY, float destWidth, float destHeight);
void aqtAddTransformedImageWithBitmap(const void *bitmap, int pixWide, int pixHigh, float clipX, float clipY, float clipWidth, float clipHeight);

