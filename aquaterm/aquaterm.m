//
//  aquaterm.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//
#include "aquaterm.h"

#import <Foundation/Foundation.h>

#import "AQTClientManager.h"
#import "AQTPlotBuilder.h"

static void (*_aqtEventHandlerPtr)(int, const char *);
static void (*_aqtErrorHandlerPtr)(const char *);
static NSAutoreleasePool *_pool;
static AQTClientManager *_clientManager;
static AQTPlotBuilder *_selectedBuilder;
static id observer;

@implementation AQTObserver : NSObject
{
}
- (void)connectionDidDie:(id)x
{
   NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   // Make sure we can't access any invalid objects:
   _selectedBuilder = nil;
}   
@end

/*" Class initialization etc."*/
int aqtInit(void)
{
   if (!_pool)
   {
      _pool = [[NSAutoreleasePool alloc] init];
   }
   _clientManager = [AQTClientManager sharedManager];
   observer = [[AQTObserver alloc] init];
   [[NSNotificationCenter defaultCenter] addObserver:observer
                                            selector:@selector(connectionDidDie:)
                                                name:NSConnectionDidDieNotification
                                              object:nil];
   
   return [_clientManager connectToServer]?0:1;
}

void aqtTerminate(void)
{
   [_clientManager logMessage:@"adapter dealloc, terminating connection." logLevel:3];
   [[NSNotificationCenter defaultCenter] removeObserver:observer];
   [_clientManager terminateConnection];
   [observer release];
   [_pool release];
   _pool = nil;
}

void _aqtErrorTranslator(NSString *errMsg)
{
   NSLog(@"_aqtErrorTranslator --- %@", errMsg);
   _aqtErrorHandlerPtr([errMsg UTF8String]);
}

void aqtSetErrorHandler(void (*func)(const char *msg))
{
   _aqtErrorHandlerPtr = func;
   [_clientManager setErrorHandler:_aqtErrorTranslator];
}

void _aqtEventTranslator(int index, NSString *event)
{
   NSLog(@"_aqtEventTranslator --- %@ from %d", event, index);
   _aqtEventHandlerPtr(index, [event UTF8String]);
}

void aqtSetEventHandler(void (*func)(int ref, const char *event))
{
   _aqtEventHandlerPtr = func;
   [_clientManager setEventHandler:_aqtEventTranslator];
}

/*" Control operations "*/
void aqtOpenPlot(int refNum) // FIXME: retval?
{
   _selectedBuilder = [_clientManager newPlotWithIndex:refNum];
}

int aqtSelectPlot(int refNum)
{
   int didChangePlot = 0;
   AQTPlotBuilder *tmpBuilder = [_clientManager selectPlotWithIndex:refNum];
   if (tmpBuilder != nil)
   {
      _selectedBuilder = tmpBuilder;
      didChangePlot = 1;
   }
   return didChangePlot;
}

void aqtSetPlotSize(float width, float height)
{
   [_selectedBuilder setSize:NSMakeSize(width, height)];
}

void aqtSetPlotTitle(const char *title)
{
   [_selectedBuilder setTitle:title?[NSString stringWithCString:title]:@"Untitled"];
}

void aqtRenderPlot(void)
{
   if(_selectedBuilder)
   {
      [_clientManager renderPlot];
   }
   else
   {
      // Just inform user about what is going on...
      [_clientManager logMessage:@"Warning: No plot selected" logLevel:2];
   }   
}

void aqtClearPlot(void)
{
   [_clientManager clearPlot];
}

void aqtClosePlot(void)
{
   [_clientManager closePlot];
   _selectedBuilder = nil;
}

/*" Event handling "*/
void aqtSetAcceptingEvents(int flag)
{
   [_clientManager setAcceptingEvents:flag?YES:NO]; 
}


int aqtGetLastEvent(char *buffer)
{
   NSString *event = [_clientManager lastEvent];
   strncpy(buffer, [event UTF8String], MIN(EVENTBUF_SIZE - 1, [event length]));
   buffer[MIN(EVENTBUF_SIZE - 1, [event length])] = '\0';
   return 0;
}


int aqtWaitNextEvent(char *buffer)
{
   NSString *event;
   BOOL isRunning;
   [_clientManager setAcceptingEvents:YES]; 
   do {
      isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
      event = [_clientManager lastEvent];
      isRunning = [event isEqualToString:@"0"]?YES:NO;
   } while (isRunning);
   [_clientManager setAcceptingEvents:NO];
   
   strncpy(buffer, [event UTF8String], MIN(EVENTBUF_SIZE - 1, [event length]));
   buffer[MIN(EVENTBUF_SIZE - 1, [event length])] = '\0';
   return 0;
}

/*" Plotting related commands "*/

/*" Colormap (utility  "*/
int aqtColormapSize(void)
{
   int size = 0;
   if (_selectedBuilder)
   {
      size = [_selectedBuilder colormapSize];
   }
   else
   {
      // Just inform user about what is going on...
      [_clientManager logMessage:@"Warning: No plot selected" logLevel:2];
   }
   return size;
}

void aqtSetColormapEntry(int entryIndex, float r, float g, float b)
{
   AQTColor tmpColor;
   tmpColor.red = r;
   tmpColor.green = g;
   tmpColor.blue = b;
   [_selectedBuilder setColor:tmpColor forColormapEntry:entryIndex];
}

void aqtGetColormapEntry(int entryIndex, float *r, float *g, float *b)
{
   AQTColor tmpColor = [_selectedBuilder colorForColormapEntry:entryIndex];
   *r = tmpColor.red;
   *g = tmpColor.green;
   *b = tmpColor.blue;
}

void aqtTakeColorFromColormapEntry(int index)
{
   [_selectedBuilder takeColorFromColormapEntry:index];
}

void aqtTakeBackgroundColorFromColormapEntry(int index)
{
   [_selectedBuilder takeBackgroundColorFromColormapEntry:index];
}

/*" Color handling "*/
void aqtSetColor(float r, float g, float b)
{
   AQTColor newColor;
   newColor.red = r;
   newColor.green = g;
   newColor.blue = b;
   [_selectedBuilder setColor:newColor];
}

void aqtSetBackgroundColor(float r, float g, float b)
{
   AQTColor newColor;
   newColor.red = r;
   newColor.green = g;
   newColor.blue = b;
   [_selectedBuilder setBackgroundColor:newColor];
}

void aqtGetCurrentColor(float *r, float *g, float *b)
{
   AQTColor tmpColor = [_selectedBuilder color];
   *r = tmpColor.red;
   *g = tmpColor.green;
   *b = tmpColor.blue;
}

/*" Text handling "*/
 void aqtSetFontname(const char *newFontname)
{
    if (newFontname != nil)
    {
       [_selectedBuilder setFontname:[NSString stringWithCString:newFontname]];
    }
}

void aqtSetFontsize(float newFontsize)
{
   [_selectedBuilder setFontsize:newFontsize];
}

void aqtAddLabel(const char *text, float x, float y, float angle, int just)
{
   if (text != nil)
   {
      [_selectedBuilder addLabel:[NSString stringWithCString:text] position:NSMakePoint(x,y) angle:angle justification:just];
   }
}

/*" Line handling "*/
void aqtSetLinewidth(float newLinewidth)
{
   [_selectedBuilder setLinewidth:newLinewidth];
}

void aqtSetLineCapStyle(int capStyle)
{
   [_selectedBuilder setLineCapStyle:capStyle];
}

void aqtMoveTo(float x, float y)
{
   [_selectedBuilder moveToPoint:NSMakePoint(x, y)];
}

void aqtAddLineTo(float x, float y)
{
   [_selectedBuilder addLineToPoint:NSMakePoint(x, y)];
}

void aqtAddPolyline(float *x, float *y, int pc)
{
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}

/*" Rect and polygon handling"*/
 void aqtMoveToVertex(float x, float y)
{
    [_selectedBuilder moveToVertexPoint:NSMakePoint(x,y)];
}

void aqtAddEdgeToVertex(float x, float y)
{
   [_selectedBuilder addEdgeToPoint:NSMakePoint(x,y)];
}

void aqtAddPolygon(float *x, float *y, int pc)
{
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}

void aqtAddFilledRect(float originX, float originY, float width, float height)
{
   // If the filled rect covers a substantial area, it is worthwile to clear it first.
   NSRect aRect = NSMakeRect(originX, originY, width, height);
   if (NSWidth(aRect)*NSHeight(aRect) > 100.0)
   {
      [_clientManager clearPlotRect:aRect];
   }
   [_selectedBuilder addFilledRect:aRect];
}

void aqtEraseRect(float originX, float originY, float width, float height)
{
   [_clientManager clearPlotRect:NSMakeRect(originX, originY, width, height)];
}

/*" Image handling "*/
/*
 void aqtSetImageTransformM11(float m11, float m12, float m21, float m22, float tX, float tY)
{
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}

void aqtResetImageTransform(void){
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}

void aqtAddImageWithBitmap(const void *bitmap, NSSize bitmapSize, NSRect destBounds)
{
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}

void aqtAddTransformedImageWithBitmap(const void *bitmap, NSSize bitmapSize, NSRect destBounds)
{
   NSLog(@"implement line %d in %s", __LINE__, __FILE__);
}
*/

