//
//  AQTAdapter.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/NSString.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSDictionary.h>



enum {
  AQTButtLineCapStyle = 0,
  AQTRoundLineCapStyle = 1,
  AQTSquareLineCapStyle = 2
};

enum {
   AQTAlignLeft = 0x00,
   AQTAlignCenter = 0x01,
   AQTAlignRight = 0x02,
   AQTAlignMiddle = 0x00,
   AQTAlignBaseline = 0x04,
   AQTAlignBottom = 0x08,
   AQTAlignTop = 0x10
};


@protocol AQTConnectionProtocol;
@class AQTPlotBuilder;
@interface AQTAdapter : NSObject
{
  /*" All instance variables are private. "*/
  NSDistantObject <AQTConnectionProtocol> *_server; /* The viewer app's (AquaTerm) default connection */
  NSMutableDictionary *_builders; /* The objects responsible for assembling a model object from client's calls. */
  AQTPlotBuilder *_selectedBuilder;
  void (*_errorHandler)(NSString *msg);	/* A callback function optionally installed by the client */
  void (*_eventHandler)(int index, NSString *event); /* A callback function optionally installed by the client */
  id _eventBuffer;
  id _aqtReserved1;
  id _aqtReserved2;
}

/*" Class initialization "*/
- (id)init;
- (id)initWithServer:(id)localServer;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;
- (void)setEventHandler:(void (*)(int index, NSString *event))fPtr;

  /*" Control operations "*/
- (void)openPlotWithIndex:(int)refNum; 
- (BOOL)selectPlotWithIndex:(int)refNum;
- (void)setPlotSize:(NSSize)canvasSize;
- (void)setPlotTitle:(NSString *)title;
- (void)renderPlot;
- (void)clearPlot;
- (void)closePlot;

  /*" Event handling "*/
- (void)setAcceptingEvents:(BOOL)flag;
- (NSString *)lastEvent;
- (NSString *)waitNextEvent; 

/*" Plotting related commands "*/

/*" Colormap (utility) "*/
- (int)colormapSize;
- (void)setColormapEntry:(int)entryIndex red:(float)r green:(float)g blue:(float)b;
- (void)getColormapEntry:(int)entryIndex red:(float *)r green:(float *)g blue:(float *)b;
- (void)takeColorFromColormapEntry:(int)index;
- (void)takeBackgroundColorFromColormapEntry:(int)index;

  /*" Color handling "*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b;
- (void)getCurrentColorRed:(float *)r green:(float *)g blue:(float *)b;

  /*" Text handling "*/
- (void)setFontname:(NSString *)newFontname;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle align:(int)just;// FIXME: position --> atPoint

  /*" Line handling "*/
- (void)setLinewidth:(float)newLinewidth;
- (void)setLineCapStyle:(int)capStyle;
- (void)moveToPoint:(NSPoint)point;  
- (void)addLineToPoint:(NSPoint)point; 
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc;
//- (void)addPolylineWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc;

  /*" Rect and polygon handling"*/
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc;
- (void)moveToVertexPoint:(NSPoint)point;
- (void)addEdgeToPoint:(NSPoint)point; 
//- (void)addPolygonWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc;
- (void)addFilledRect:(NSRect)aRect;
- (void)eraseRect:(NSRect)aRect;

  /*" Image handling "*/
- (void)setImageTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 tX:(float)tX tY:(float)tY;
- (void)resetImageTransform;
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; 
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds; 
@end
