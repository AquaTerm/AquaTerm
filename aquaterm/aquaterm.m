//
//  aquaterm.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//
#include "aquaterm.h"

#import <stdint.h>
#import <Foundation/Foundation.h>
#import "AQTAdapter.h"

static void (*_aqtEventHandlerPtr)(int32_t, const char *);
static NSAutoreleasePool *_pool;
static AQTAdapter *_adapter;
static BOOL _mayCleanPool = YES;

void _aqtCleanPool(void)
{
   // NSLog(@"#arpool=%d", [NSAutoreleasePool autoreleasedObjectCount]);
   if (_mayCleanPool)
   {
      [_pool release];
      _pool = [[NSAutoreleasePool alloc] init];
   }
   else
   {
      // NSLog(@"Cleaning disabled");
   }
}

/*" Class initialization etc."*/
int32_t aqtInit(void) // FIXME: retval?
{
   if (!_pool)
   {
      _pool = [[NSAutoreleasePool alloc] init];
   }
   if (!_adapter)
   {
      _adapter = [[AQTAdapter alloc] init];
   }

   return (_adapter==nil)?1:0;
}

void aqtTerminate(void)
{
   [_adapter release];
   _adapter = nil;
   [_pool release];
   _pool = nil;
}

void _aqtEventTranslator(int32_t index, NSString *event)
{
   // NSLog(@"_aqtEventTranslator --- %@ from %d", event, index);
   _mayCleanPool = NO;
   _aqtEventHandlerPtr(index, [event UTF8String]);
   _mayCleanPool = YES;
}

void aqtSetEventHandler(void (*func)(int32_t ref, const char *event))
{
   _aqtEventHandlerPtr = func;
   [_adapter setEventHandler:_aqtEventTranslator];
}

/*" Control operations "*/
void aqtOpenPlot(int32_t refNum) // FIXME: retval?
{
   [_adapter openPlotWithIndex:refNum];
}

int32_t aqtSelectPlot(int32_t refNum) // FIXME: retval?
{
   return [_adapter selectPlotWithIndex:refNum]?1:0;
}

void aqtSetPlotSize(float width, float height)
{
   [_adapter setPlotSize:NSMakeSize(width, height)];
}

void aqtSetPlotTitle(const char *title)
{
    [_adapter setPlotTitle:title?[NSString stringWithCString:title encoding: NSISOLatin1StringEncoding]:@"Untitled"];
}

void aqtRenderPlot(void)
{
   [_adapter renderPlot];
   _aqtCleanPool();
}

void aqtClearPlot(void)
{
   [_adapter clearPlot];
}

void aqtClosePlot(void)
{
   [_adapter closePlot];
}

/*" Event handling "*/
void aqtSetAcceptingEvents(int32_t flag)
{
   [_adapter setAcceptingEvents:flag?YES:NO];
}

int32_t aqtGetLastEvent(char *buffer) // FIXME: retval?
{
   NSString *event = [_adapter lastEvent];
   // Perform a lossy conversion from UTF8 to ASCII
   NSString *eventStr = [[NSString alloc] initWithData:[event dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                          encoding:NSASCIIStringEncoding];
   const char *cStr = [eventStr cStringUsingEncoding:NSASCIIStringEncoding];
   int copyLen = MIN(AQT_EVENTBUF_SIZE - 1, strlen(cStr));
   strncpy(buffer, cStr, copyLen);
   buffer[copyLen] = '\0';
   [eventStr release];
   return 0;
}

int32_t aqtWaitNextEvent(char *buffer) // FIXME: retval?
{
   NSString *event  = [_adapter waitNextEvent];
  // Perform a lossy conversion from UTF8 to ASCII
  NSString *eventStr = [[NSString alloc] initWithData:[event dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                             encoding:NSASCIIStringEncoding];
  const char *cStr = [eventStr cStringUsingEncoding:NSASCIIStringEncoding];
  int copyLen = MIN(AQT_EVENTBUF_SIZE - 1, strlen(cStr));
  strncpy(buffer, cStr, copyLen);
  buffer[copyLen] = '\0';
  [eventStr release];
  return 0;
}

void aqtEventProcessingMode()
{
   // FIXME: Add this to adapter?
   [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
   _aqtCleanPool();
}

/*" Plotting related commands "*/

/*" Clip rect, applies to all objects "*/
void aqtSetClipRect(float originX, float originY, float width, float height)
{
   [_adapter setClipRect:NSMakeRect(originX, originY, width, height)];
}

void aqtSetDefaultClipRect(void)
{ 
   [_adapter setDefaultClipRect];
}

/*" Colormap (utility  "*/
int32_t aqtColormapSize(void)
{
   return [_adapter colormapSize];
}

void aqtSetColormapEntryRGBA(int32_t entryIndex, float r, float g, float b, float a)
{
  [_adapter setColormapEntry:entryIndex red:r green:g blue:b alpha:a];
}

void aqtGetColormapEntryRGBA(int32_t entryIndex, float *r, float *g, float *b, float *a)
{
  [_adapter getColormapEntry:entryIndex red:r green:g blue:b alpha:a];
}

void aqtSetColormapEntry(int32_t entryIndex, float r, float g, float b)
{
   [_adapter setColormapEntry:entryIndex red:r green:g blue:b];
}

void aqtGetColormapEntry(int32_t entryIndex, float *r, float *g, float *b)
{
   [_adapter getColormapEntry:entryIndex red:r green:g blue:b];
}

void aqtTakeColorFromColormapEntry(int32_t index)
{
   [_adapter takeColorFromColormapEntry:index];
}

void aqtTakeBackgroundColorFromColormapEntry(int32_t index)
{
   [_adapter takeBackgroundColorFromColormapEntry:index];
}

/*" Color handling "*/
void aqtSetColorRGBA(float r, float g, float b, float a)
{
  [_adapter setColorRed:r green:g blue:b alpha:a];
}

void aqtSetBackgroundColorRGBA(float r, float g, float b, float a)
{
  [_adapter setBackgroundColorRed:r green:g blue:b alpha:a];
}

void aqtGetColorRGBA(float *r, float *g, float *b, float *a)
{
  [_adapter getColorRed:r green:g blue:b alpha:a];
}

void aqtGetBackgroundColorRGBA(float *r, float *g, float *b, float *a)
{
  [_adapter getBackgroundColorRed:r green:g blue:b alpha:a];
}

void aqtSetColor(float r, float g, float b)
{
   [_adapter setColorRed:r green:g blue:b];
}

void aqtSetBackgroundColor(float r, float g, float b)
{
   [_adapter setBackgroundColorRed:r green:g blue:b];
}

void aqtGetColor(float *r, float *g, float *b)
{
   [_adapter getColorRed:r green:g blue:b];
}

void aqtGetBackgroundColor(float *r, float *g, float *b)
{
   [_adapter getBackgroundColorRed:r green:g blue:b];
}

/*" Text handling "*/
 void aqtSetFontname(const char *newFontname)
{
    if (newFontname != nil)
    {
       [_adapter setFontname:[NSString stringWithCString:newFontname encoding: NSISOLatin1StringEncoding]];
    }
}

void aqtSetFontsize(float newFontsize)
{
   [_adapter setFontsize:newFontsize];
}

void aqtAddLabel(const char *text, float x, float y, float angle, int32_t align)
{
   if (text != nil)
   {
      [_adapter addLabel:[NSString stringWithCString:text encoding: NSISOLatin1StringEncoding] atPoint:NSMakePoint(x,y) angle:angle align:align];
   }
}

void aqtAddShearedLabel(const char *text, float x, float y, float angle, float shearAngle, int32_t align)
{
   if (text != nil)
   {
      [_adapter addLabel:[NSString stringWithCString:text encoding: NSISOLatin1StringEncoding] atPoint:NSMakePoint(x,y) angle:angle shearAngle:shearAngle align:align];
   }
}


/*" Line handling "*/
void aqtSetLinewidth(float newLinewidth)
{
   [_adapter setLinewidth:newLinewidth];
}

void aqtSetLineCapStyle(int32_t capStyle)
{
   [_adapter setLineCapStyle:capStyle];
}

void aqtMoveTo(float x, float y)
{
   [_adapter moveToPoint:NSMakePoint(x, y)];
}

void aqtAddLineTo(float x, float y)
{
   [_adapter addLineToPoint:NSMakePoint(x, y)];
}

void aqtAddPolyline(float *x, float *y, int32_t pc)
{
   int32_t i; 
   if (pc > 1)
   {
      [_adapter moveToPoint:NSMakePoint(x[0], y[0])];
      for (i=1; i<pc; i++)
      {
         [_adapter addLineToPoint:NSMakePoint(x[i], y[i])];
      }
   }   
}

void aqtSetLinestylePattern(float *newPattern, int32_t newCount, float newPhase)
{
   [_adapter setLinestylePattern:newPattern count:newCount phase:newPhase];
}

void aqtSetLinestyleSolid(void)
{
   [_adapter setLinestyleSolid];
}

/*" Rect and polygon handling"*/
 void aqtMoveToVertex(float x, float y)
{
    [_adapter moveToVertexPoint:NSMakePoint(x,y)];
}

void aqtAddEdgeToVertex(float x, float y)
{
   [_adapter addEdgeToVertexPoint:NSMakePoint(x,y)];
}

void aqtAddPolygon(float *x, float *y, int32_t pc)
{
   int32_t i;
   if (pc > 1)
   {
      [_adapter moveToVertexPoint:NSMakePoint(x[0], y[0])];
      for (i=1; i<pc; i++)
      {
         [_adapter addEdgeToVertexPoint:NSMakePoint(x[i], y[i])];
      }
   }
}

void aqtAddFilledRect(float originX, float originY, float width, float height)
{
   [_adapter addFilledRect:NSMakeRect(originX, originY, width, height)];
}

void aqtEraseRect(float originX, float originY, float width, float height)
{
   [_adapter eraseRect:NSMakeRect(originX, originY, width, height)];
}

/*" Image handling "*/
 void aqtSetImageTransform(float m11, float m12, float m21, float m22, float tX, float tY)
{
    [_adapter setImageTransformM11:m11 m12:m12 m21:m21 m22:m22 tX:tX tY:tY];
}

void aqtResetImageTransform(void)
{
   [_adapter resetImageTransform];
}

void aqtAddImageWithBitmap(const void *bitmap, int32_t pixWide, int32_t pixHigh, float originX, float originY, float width, float height)
{
   [_adapter addImageWithBitmap:bitmap size:NSMakeSize(pixWide, pixHigh) bounds:NSMakeRect(originX, originY, width, height)];
}

// FIXME: This function maps to a deprecated method in AQTAdapter. It overrides the global clipRect setting.
void aqtAddTransformedImageWithBitmap(const void *bitmap, int32_t pixWide, int32_t pixHigh, float originX, float originY, float width, float height)
{
   [_adapter addTransformedImageWithBitmap:bitmap size:NSMakeSize(pixWide, pixHigh) clipRect:NSMakeRect(originX, originY, width, height)];
}

