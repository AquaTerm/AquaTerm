#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <aquaterm/aquaterm.h>

#include "const-c.inc"

MODULE = Graphics::AquaTerm		PACKAGE = Graphics::AquaTerm		

INCLUDE: const-xs.inc

PROTOTYPES: DISABLE

REQUIRE: 1.9508

void
aqtAddEdgeToVertex(x, y)
	float	x
	float	y

void
aqtAddFilledRect(originX, originY, width, height)
	float	originX
	float	originY
	float	width
	float	height

void
c_aqtAddImageWithBitmap(bitmap, pixWide, pixHigh, destX, destY, destWidth, destHeight)
	char *	bitmap
	int	pixWide
	int	pixHigh
	float	destX
	float	destY
	float	destWidth
	float	destHeight
	CODE:
		aqtAddImageWithBitmap((const void *)bitmap, pixWide, pixHigh, destX, destY, destWidth, destHeight);
	
void
aqtAddLabel(text, x, y, angle, align)
	char *	text
	float	x
	float	y
	float	angle
	int	align

void
aqtAddShearedLabel(text, x, y, angle, shear, align)
	char *	text
	float	x
	float	y
	float	angle
	float	shear
	int	align

void
aqtAddLineTo(x, y)
	float	x
	float	y

void
c_aqtAddPolygon(x, y, pointCount)
	char *	x
	char *	y
	int	pointCount
    CODE:
    	aqtAddPolygon((float *)x, (float *)y, pointCount);

void
c_aqtAddPolyline(x, y, pointCount)
	char *	x
	char *	y
	int	pointCount
    CODE:
    	aqtAddPolyline((float *)x, (float *)y, pointCount);
  
void
c_aqtAddTransformedImageWithBitmap(bitmap, pixWide, pixHigh, clipX, clipY, clipWidth, clipHeight)
	char *	bitmap
	int	pixWide
	int	pixHigh
	float	clipX
	float	clipY
	float	clipWidth
	float	clipHeight
	CODE:
		aqtAddTransformedImageWithBitmap((const void *)bitmap, pixWide, pixHigh, clipX, clipY, clipWidth, clipHeight);

void
aqtClearPlot()

void
aqtClosePlot()

int
aqtColormapSize()

void
aqtEraseRect(originX, originY, width, height)
	float	originX
	float	originY
	float	width
	float	height

void
aqtGetBackgroundColor(OUTLIST float r, OUTLIST float g, OUTLIST float b)

void
aqtGetColor(OUTLIST float r, OUTLIST float g, OUTLIST float b)

void
aqtGetColormapEntry(int entryIndex, OUTLIST float r, OUTLIST float g, OUTLIST float b)

int
c_aqtGetLastEvent(buffer)
	char *	buffer
	CODE:
		RETVAL = aqtWaitNextEvent(buffer);
	OUTPUT:
		RETVAL
		
int
aqtInit()

void
aqtMoveTo(x, y)
	float	x
	float	y

void
aqtMoveToVertex(x, y)
	float	x
	float	y

void
aqtOpenPlot(refNum)
	int	refNum

void
aqtRenderPlot()

void
aqtResetImageTransform()

int
aqtSelectPlot(refNum)
	int	refNum

void
aqtSetAcceptingEvents(flag)
	int	flag

void
aqtSetBackgroundColor(r, g, b)
	float	r
	float	g
	float	b

void
aqtSetColor(r, g, b)
	float	r
	float	g
	float	b

void
aqtSetColormapEntry(entryIndex, r, g, b)
	int	entryIndex
	float	r
	float	g
	float	b

#void
#aqtSetEventHandler(arg0)
#	void ( * func ) ( int ref, const char * event )	arg0
#

void
aqtSetFontname(newFontname)
	char *	newFontname

void
aqtSetFontsize(newFontsize)
	float	newFontsize

void
aqtSetImageTransform(m11, m12, m21, m22, tX, tY)
	float	m11
	float	m12
	float	m21
	float	m22
	float	tX
	float	tY

void
aqtSetLineCapStyle(capStyle)
	int	capStyle

void
aqtSetLinewidth(newLinewidth)
	float	newLinewidth

void
aqtSetPlotSize(width, height)
	float	width
	float	height

void
aqtSetPlotTitle(title)
	char *	title

void
aqtTakeBackgroundColorFromColormapEntry(index)
	int	index

void
aqtTakeColorFromColormapEntry(index)
	int	index

void
aqtTerminate()

int
c_aqtWaitNextEvent(buffer)
	char *	buffer
	CODE:
		RETVAL = aqtWaitNextEvent(buffer);
	OUTPUT:
		RETVAL

void
aqtSetClipRect(originX, originY, width, height)
	float	originX
	float	originY
	float	width
	float	height
	
void
aqtSetDefaultClipRect();

void
c_aqtSetLinestylePattern(newPattern, newCount, newPhase)
	char *	newPattern
	int 	newCount
	float	newPhase
    CODE:
    	aqtSetLinestylePattern((float *)newPattern, newCount, newPhase);

void
aqtSetLinestyleSolid();
